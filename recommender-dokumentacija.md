# Dokumentacija sistema preporuka (recommender)

Dokument opisuje kako je preporuka smještaja stvarno implementirana u ovom repozitoriju.
Sav kod se nalazi u `server/ebooking-api/API/Services/RecommendationService/`, a izlaže se
kroz `GET /api/Recommendation/suggestions`.

## 1. Pregled

Preporuka je **collaborative filtering** zasnovan na **ML.NET Matrix Factorization**
(`Microsoft.ML.Recommender`). Model uči latentne faktore iz matrice `korisnik × smještaj`
popunjene ocjenama, pa za prijavljenog korisnika predviđa ocjenu za svaki aktivan smještaj.
Konačni poredak je kombinacija te predikcije i prosječne ocjene smještaja (`ReviewScore`).

Sistem ima dvije putanje:

| Putanja | Kada se koristi | Poredak | `FromModel` |
|---|---|---|---|
| Glavna (ML) | model `MLModels/MLmodel.zip` postoji na disku | ML predikcija + ponderisani `ReviewScore` | `true` |
| Fallback | model još nije istreniran / fajl ne postoji | samo `ReviewScore` (`ByReviewScore`) | `false` |

Klijent razlikuje putanje po `FromModel`; kad je `false`, API vraća poruku
*"The recommendation model is still being prepared, so the top-rated accommodations are shown instead."*

## 2. Ulazni signali (trening skup)

Trening skup gradi `DataPreparationService.GetTrainingData()`. Svaki red je
`AccommodationRating { CustomerId, AccommodationId, Rating }`, gdje su oba id-a `Guid`
pretvoren u `string` (matrix factorization traži kategorijske ključeve).

Dva izvora signala:

1. **Eksplicitni — `Review.Rating`.** Sve neobrisane recenzije (`!r.IsDeleted`).
   Ocjena je cijeli broj **1–10** (validacija u `FeedbackController`, konstante
   `MinimumRating` / `MaximumRating`).

2. **Implicitni — završene rezervacije.** Rezervacije sa `Status == ReservationStatus.Completed`
   i `EndDate < DateTime.UtcNow.Date`, tj. boravci koji su stvarno realizovani. Njima se
   dodjeljuje konstantna ocjena `DataPreparationService.ImplicitStayRating = 6f` — blago
   iznad sredine skale 1–10, jer završen boravak jeste pozitivan signal, ali slabiji i
   manje pouzdan od ocjene koju je korisnik svjesno dao.

**Deduplikacija:** eksplicitna ocjena uvijek pobjeđuje. Implicitni red se dodaje samo ako
za taj par `(CustomerId, AccommodationId)` još ne postoji recenzija — u kodu preko
`HashSet` para i `seen.Add(...)`. Tako korisnik koji je boravio i ostavio ocjenu 3 ne
dobije istovremeno i lažni signal 6.

## 3. Trening

`AccommodationRecommendationService.TrainModel()` gradi pipeline:

1. `MapValueToKey("CustomerIdKey", "CustomerId")` — string id → ključ (indeks kolone matrice).
2. `MapValueToKey("AccommodationIdKey", "AccommodationId")` — string id → ključ (indeks reda matrice).
3. `MatrixFactorization` sa:
   - `labelColumnName: "Rating"`
   - `matrixColumnIndexColumnName: CustomerKeyColumn`
   - `matrixRowIndexColumnName: AccommodationKeyColumn`
   - `numberOfIterations: 20`
   - `approximationRank: 16` (`AccommodationRecommendationService.ApproximationRank`) — broj latentnih faktora

Model se serijalizuje u `MLModels/MLmodel.zip` (`SaveModel`).

**Kada se trenira:** `RecommendationModelHostedService` je `BackgroundService` koji pri
startu provjeri postoji li već model na disku. Ako postoji — preskače trening; ako ne
postoji — trenira u pozadini. Trening namjerno **ne** blokira `app.Run()`: ranije je
sinhroni trening prije pokretanja uzrokovao da `webapi` kontejner promaši health check
`start_period` i uđe u restart petlju.

## 4. Predikcija i konačni skor

`RecommendationController.GetSuggestions` uzima `customerId` **iz tokena** (ne iz rute —
ranije je ruta primala `customerId`, pa je svako mogao čitati tuđe preporuke), zatim
projektuje sve aktivne smještaje (`a.Status`) u `AccommodationCandidate(Id, ReviewScore)`
i poziva `RecommendationService.GetRecommendations(customerId, candidates)`.

`RecommendationService` lijeno učita model (`EnsureModelLoaded`, keširan u polju `_model`),
napravi `PredictionEngine<AccommodationRating, AccommodationRatingPrediction>` i za svakog
kandidata izračuna skor.

### Formula

```
skor(kandidat) = mlSkor + ReviewScoreWeight * kandidat.ReviewScore

gdje je:
  mlSkor           = engine.Predict(customerId, kandidat.Id).Score
                     odnosno UnknownPairScore (-1_000_000f) ako je predikcija NaN
  ReviewScoreWeight = 0.1f
```

Kandidati se sortiraju `OrderByDescending(skor).ThenBy(Id)`.

**Zašto oba člana.** `ReviewScore` je zaokružen prosjek recenzija smještaja
(`ReviewService.CalculateReviewScore`, `decimal(3,1)`, opseg 0–10) i živi na istoj skali
kao i ocjene na kojima je model treniran, pa se dva člana mogu direktno sabrati. Težina
`0.1` je namjerno mala: ML predikcija ostaje dominantna i personalizovana, dok
`ReviewScore` (maksimalni doprinos `+1.0`) razdvaja smještaje koje model ocjenjuje slično
i služi kao prior za korisnike o kojima model zna malo. Prije ovog ispravka `ReviewScore`
se prosljeđivao kroz cijeli poziv ali se čitao samo u fallback putanji, pa su
nerazlučivi kandidati završavali poredani po `Id` — slabo ocijenjen smještaj je mogao
preteći odlično ocijenjen.

**`UnknownPairScore` umjesto `NaN`.** Matrix factorization vraća `NaN` za smještaj koji
se nije pojavio u trening podacima (npr. novi oglas). Takvi kandidati dobijaju bazu
`-1_000_000f`, što ih drži ispod svakog kandidata kojeg model umije ocijeniti, ali ih
međusobno i dalje poređa po `ReviewScore` — što je jedini signal koji za njih postoji.

### Fallback

Ako `MLModels/MLmodel.zip` ne postoji, `EnsureModelLoaded` loguje upozorenje i vrati
`null`, pa `GetRecommendations` vraća `ByReviewScore(candidates)`:
`OrderByDescending(ReviewScore).ThenBy(Id)` — dakle najbolje ocijenjeni smještaji,
bez personalizacije, uz `FromModel = false`.

## 5. Paginacija

Rangiranje se radi nad cijelom listom kandidata, a stranica se reže tek nakon sortiranja
(`Skip((page - 1) * pageSize).Take(pageSize)`). Tek za id-eve sa te stranice se dovlače
puni entiteti, mapiraju u `AccommodationGET` i dopunjuju slikama i sadržajima
(`_imageService.Attach`, `_catalog.AttachAmenities`). `total` u `PagedResponse` je broj
svih rangiranih smještaja.

## 6. Ograničenja

- Hladan start: dok nema recenzija ni završenih rezervacija, model nema šta naučiti i
  preporuke se svode na `ReviewScore`.
- Model se ne re-trenira automatski nakon prvog treninga — postojanje fajla
  `MLModels/MLmodel.zip` je jedini uslov za preskakanje treninga. Za osvježavanje modela
  fajl treba obrisati (ili dodati zakazani re-trening).
- `ReviewScoreWeight` je fiksna konstanta, nije evaluirana kroz A/B test niti podešena
  na validacionom skupu.
