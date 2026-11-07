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

## 4. Predikcija i konačni skor (hibridni model)

Collaborative filtering iz poglavlja 3 ostaje osnova, ali konačni poredak je **hibridan**:
pored ML predikcije koristi i signale iz prijave teme — historiju rezervacija, mjesta koja je
korisnik već posjetio, sadržaje smještaja koje je bukirao i fizičku lokaciju korisnika.
Svaki signal je stvaran podatak iz aplikacijskog toka (rezervacije, lokacija smještaja,
veze smještaj–sadržaj, koordinate koje šalje mobilni klijent), ne seed niti neiskorišteno polje.

Podatke priprema `RecommendationDataService`:

- `GetActiveCandidates()` — svi aktivni smještaji sa gradom, tipom, cijenom, koordinatama i
  listom sadržaja (`AccommodationDetailsAmenities`).
- `GetCustomerProfile(customerId, latitude, longitude)` — iz `Completed` i `Confirmed`
  rezervacija kupca: skup već posjećenih smještaja, skup gradova u kojima je boravio i
  učestalost svakog sadržaja u smještajima koje je bukirao. Koordinate su opcione i
  šalje ih mobilni Explore ekran.

### 4.1. `GET /api/Recommendation/suggestions`

Za svakog kandidata kojeg kupac još nije posjetio `RecommendationService.GetRecommendations`
sabira doprinose i bilježi razlog za svaki:

| Signal | Doprinos | Razlog koji vidi korisnik |
|---|---|---|
| ML predikcija (MF) | predikcija 1–10 (samo ako model poznaje par) | „Guests with stays similar to yours rated it highly (predicted 8.4/10)" — kad je ≥ 6 |
| Grad ranijeg boravka | `+1.5` | „In Mostar, where you have stayed before" |
| Sadržaji kao u bukiranim smještajima | `2.0 × udio` (udio = težina zajedničkih sadržaja / ukupna težina profila) | „Offers Wi-Fi, Parking, Pool, like the places you booked" |
| Blizina trenutnoj lokaciji (≤ 20 km) | `1.0 × (1 − d/20)` | „3.2 km from your current location" |
| Prosječna ocjena smještaja | `0.1 × ReviewScore` | „Highly rated by guests (8.7/10)" — kad je ≥ 8 |

Razlozi se sortiraju po veličini doprinosa; prvi je `Reason`, a svi su u `Reasons`.
Ako nijedan signal ne prelazi prag, razlog je „Popular with guests (x/10)" ili
„A new place you have not tried yet". Odgovor je `RecommendedAccommodationGET`
(`AccommodationGET` + `Reason`, `Reasons`, `RecommendationScore`); mobilni klijent razlog
prikazuje na kartici u sekciji „Suggested for you" i na ekranu svih preporuka.

### 4.2. `GET /api/Recommendation/similar/{accommodationId}`

Preporuke ispod detalja smještaja („You might also like"). Sličnost sa izvornim smještajem:

| Signal | Doprinos | Razlog |
|---|---|---|
| Isti grad | `+2.0` | „Also in Sarajevo" |
| Isti tip smještaja | `+1.0` | „Also a villa" |
| Zajednički sadržaji (Jaccard) | `2.0 × J` | „Shares 4 amenities, e.g. Wi-Fi, Parking" |
| Slična cijena (bliskost > 0.6) | `1.0 × bliskost` | „Similar price (120 per night)" |
| Personalizacija (MF) | `0.2 × predikcija` | „Matches your past stays (predicted 7.9/10)" |
| Prosječna ocjena | `0.1 × ReviewScore` | — |

### 4.3. Kada model ne postoji

Ako `MLModels/MLmodel.zip` još nije istreniran, ML doprinos se izostavlja, a ostali
signali i dalje rade; `FromModel = false` i API to javlja u poruci odgovora.

## 5. Paginacija

Rangiranje se radi nad cijelom listom kandidata, a stranica se reže tek nakon sortiranja
(`Skip((page - 1) * pageSize).Take(pageSize)`). Tek za id-eve sa te stranice se dovlače
puni entiteti, mapiraju u `RecommendedAccommodationGET` i dopunjuju slikama i sadržajima.
`total` u `PagedResponse` je broj svih rangiranih smještaja.

## 6. Ograničenja

- Hladan start: novi kupac nema historiju, pa preporuke zavise od lokacije i ocjena.
- Model se ne re-trenira automatski nakon prvog treninga — postojanje fajla
  `MLModels/MLmodel.zip` je jedini uslov za preskakanje treninga. Za osvježavanje modela
  fajl treba obrisati (ili dodati zakazani re-trening).
- Težine signala su fiksne konstante u `RecommendationService`, nisu evaluirane kroz
  A/B test niti podešene na validacionom skupu.
