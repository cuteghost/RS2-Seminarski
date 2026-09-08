# eBooking — seminarski rad iz predmeta Razvoj softvera II

Student: Dževad Alibegović, indeks IB170171

Sistem se sastoji od REST API-ja (.NET 8), pomoćnog Messenger servisa (SignalR), PaymentApp
servisa (PayPal), RabbitMQ posrednika i MSSQL baze, te dva Flutter klijenta — desktop
(administracija, Windows) i mobilni (klijentska aplikacija, Android).

---

## 1. Pristupni podaci

### 1.1. Nalozi u aplikaciji

Prijava se vrši **email adresom**. Lozinka je za sve seed naloge ista: `Stringst`.

| Kontekst | Email | Lozinka |
|---|---|---|
| Desktop verzija (Administrator) | `admin@ebooking.com` | `Stringst` |
| Mobilna verzija (Customer) | `mobile@ebooking.com` | `Stringst` |
| Mobilna verzija (Partner) | `dude@email.com` | `Stringst` |

Dodatni nalozi iz seeda, za slučaj da je potrebno više korisnika istovremeno (npr. razgovor
između dva uređaja):

| Uloga | Email | Lozinka |
|---|---|---|
| Partner | `adriatic@email.com` | `Stringst` |
| Partner | `alpine@email.com` | `Stringst` |
| Customer | `dea@email.com` | `Stringst` |
| Customer | `lejla@email.com` | `Stringst` |
| Customer | `emir@email.com` | `Stringst` |
| Customer | `tarik@email.com` | `Stringst` |

Pored ovih naloga seed generiše još 100 partnera i 3 000 kupaca sa istom lozinkom. Njihove
email adrese su oblika `ime.prezime.<broj>@email.com`, npr. `nina.karic.500@email.com`.

### 1.2. Google i Facebook prijava

Prijava preko Google i Facebook naloga radi sa **bilo kojim privatnim nalogom**. Nije potrebno
koristiti unaprijed pripremljene test naloge — dovoljno je na ekranu prijave odabrati Google ili
Facebook i prijaviti se vlastitim računom. Sistem pri prvoj prijavi kreira korisnika u bazi.

Napomena: dugmad za Google i Facebook prijavu su aktivna samo ako je mobilna aplikacija
buildana sa odgovarajućim ključevima (vidi poglavlje 3.3). Bez ključa dugme je onemogućeno uz
objašnjenje na ekranu, umjesto da prijava padne na nativnoj grešci.

### 1.3. PayPal sandbox — plaćanje

Plaćanje se izvršava kroz stvarno PayPal sandbox okruženje. Postoje dva načina.

**A) Plaćanje karticom**

| Podatak | Vrijednost |
|---|---|
| Broj kartice | `4005 5192 0000 0004` |
| Datum isteka | `12/30` |
| CVC | `111` |

Adresa za naplatu **mora biti unesena tačno ovako**:

| Adresa | Grad | Država (state) | ZIP | Zemlja |
|---|---|---|---|---|
| 2211 N 1st St | San Jose | CA | 95131 | United States |

Adresa nije opcionalna. PayPal nad njom radi AVS provjeru i izmišljena adresa obara plaćanje
prije autorizacije, uz generičku poruku „Something happened, please try again later". Zemlja
mora biti United States jer tome odgovara sandbox business nalog.

**Ime, prezime, telefon i ostala polja mogu biti proizvoljni (dummy) podaci** — provjerava se
samo kartica i adresa.

**B) Plaćanje PayPal nalogom**

Na ekranu za plaćanje odabrati PayPal i prijaviti se ličnim sandbox nalogom:

| Podatak | Vrijednost |
|---|---|
| Sandbox URL | https://sandbox.paypal.com |
| Region | US |
| Email | `sb-5oc43852705639@personal.example.com` |
| Lozinka | `ZqSp5>l!` |

**Provjera uplate (business nalog)**

Nakon uspješne rezervacije, uplata se može provjeriti prijavom na https://sandbox.paypal.com:

| Podatak | Vrijednost |
|---|---|
| Sandbox URL | https://sandbox.paypal.com |
| Region | US |
| Email | `sb-etjqp52668828@business.example.com` |
| Lozinka | `h['1:<Ge` |

Iznos svake rezervacije treba biti vidljiv na tom nalogu.

---

## 2. Preduslovi

- Docker i Docker Compose
- Flutter SDK 3.24.0 ili noviji, Dart SDK 3.5.0 ili noviji
- Windows (za desktop aplikaciju)
- Android emulator ili fizički uređaj (za mobilnu aplikaciju)

Za testiranje razgovora između korisnika korisna su **dva emulatora** — jedan prijavljen kao
Customer, drugi kao Partner.

---

## 3. Pokretanje aplikacije

### 3.1. Konfiguracijski podaci (`.env`)

Tajne se ne nalaze u izvornom kodu. Datoteka `server/.env` nije u git repozitoriju; umjesto nje
se u istom folderu nalazi arhiva zaštićena lozinkom:

```
server/.env-tajne.zip
```

Lozinka arhive je predana kroz DL sistem, uz link na GitHub Release. Prije pokretanja arhivu
je potrebno raspakovati u isti folder, tako da nastane `server/.env`.

```powershell
cd server
# raspakovati .env-tajne.zip u ovaj folder -> nastaje .env
```

`server/.env.example` je predložak sa nazivima svih varijabli i praznim vrijednostima. Služi
kao dokumentacija, nije dovoljan za pokretanje.

> **O tajnama u git historiji.** U ranijim commitovima repozitorija postoje konfiguracijske
> vrijednosti koje su tada bile commitovane greškom (JWT ključ, PayPal i OAuth podaci). **Sve
> te vrijednosti su poništene (revoked) i više nisu aktivne.** Izdan je potpuno nov set
> kredencijala i on se isporučuje isključivo kroz `.env-tajne.zip`. Ništa iz historije se ne
> može upotrijebiti.

### 3.2. Backend (Docker Compose)

```bash
cd server
docker-compose up -d --build

# provjera stanja servisa
docker-compose ps
```

Prvo pokretanje traje duže: MSSQL kontejner se podiže, API zatim kroz EF migracije kreira šemu
i ubacuje seed podatke. `webapi` postaje `healthy` tek kad taj postupak završi, a `messenger` i
`paymentapp` čekaju na njega, pa nema potrebe za ručnim redoslijedom pokretanja.

Servisi nakon podizanja:

| Servis | Adresa |
|---|---|
| REST API | http://localhost:9999 |
| Messenger (SignalR) | http://localhost:8888 |
| PaymentApp (PayPal) | http://localhost:9090 |
| RabbitMQ Management | http://localhost:15672 |
| MSSQL baza | localhost:7777 |

Pristupni podaci za RabbitMQ Management nalaze se u `.env` datoteci
(`RABBITMQ_USERNAME`, `RABBITMQ_PASSWORD`).

Potpuno čisto ponovno pokretanje:

```bash
docker-compose down -v && docker-compose up --build
```

Baza se svaki put ponovo izgradi iz migracija i seeda, pa je rezultat uvijek isti.

### 3.3. Desktop aplikacija (Flutter Windows)

```bash
cd client/desktop
flutter pub get
flutter run -d windows
```

Adrese servisa imaju podrazumijevane vrijednosti koje odgovaraju gornjoj tabeli
(`http://localhost:9999` i `http://localhost:8888`), pa desktop aplikacija radi bez dodatnih
parametara. Ako je potrebno promijeniti adresu:

```bash
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:9999
```

| Ključ | Podrazumijevano | Čemu služi |
|---|---|---|
| `API_BASE_URL` | `http://localhost:9999` | REST API |
| `MESSENGER_URL` | `http://localhost:8888` | SignalR (Messenger) |
| `GEOCODER_URL` | `https://nominatim.openstreetmap.org` | Pretvaranje adrese u koordinate na formi lokacije |

### 3.4. Mobilna aplikacija (Flutter Android)

```bash
cd client/mobile
cp android/local.properties.example android/local.properties
flutter pub get
flutter run
```

Mobilna aplikacija ne nosi nijedan ključ u izvornom kodu. Adrese servisa imaju upotrebljive
podrazumijevane vrijednosti za Android emulator; ključevi ih nemaju.

| Ključ | Podrazumijevano | Čemu služi |
|---|---|---|
| `API_BASE_URL` | `http://10.0.2.2:9999` | REST API |
| `MESSENGER_URL` | `http://10.0.2.2:8888` | SignalR (Messenger) |
| `PAYMENT_URL` | `http://10.0.2.2:9090` | PayPal servis |
| `GOOGLE_API_KEY` | prazno | Geocoding poziv u `location_service.dart` |
| `GOOGLE_SERVER_CLIENT_ID` | prazno | OAuth web client id za Google prijavu |
| `FACEBOOK_APP_ID` | prazno | Facebook prijava |

```bash
flutter run \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com \
  --dart-define=GOOGLE_API_KEY=<geocoding-api-key> \
  --dart-define=FACEBOOK_APP_ID=<facebook-app-id>
```

Isti parametri važe i za `flutter build apk --release`. `10.0.2.2` je adresa host mašine viđena
iz Android emulatora — na fizičkom uređaju umjesto nje ide IP adresa mašine na kojoj radi
Docker, npr. `--dart-define=API_BASE_URL=http://192.168.1.10:9999`.

`android/local.properties` je nešto drugo: odatle Gradle uzima `google.api.key` za Maps SDK u
`AndroidManifest.xml`, `facebook.app.id` i `facebook.client.token` za Facebook SDK, te
`keystore.key.alias` i `keystore.password` za potpisivanje release APK-a. Nijedna od tih
vrijednosti nije u izvornom kodu. Predložak je
`client/mobile/android/local.properties.example`.

Release APK se potpisuje ključem `android/app/mykey.jks`. Taj ključ nije u repozitoriju
(`.gitignore` isključuje `*.jks`) jer je Google i Facebook prijava registrovana na njegov
SHA-1 otisak — potpisivanje bilo kojim drugim ključem obara obje prijave. Gotov APK se
isporučuje kroz GitHub Release.

Ako emulatori nisu kreirani:

```bash
flutter emulators

avdmanager create avd -n Partner -k "system-images;android-34;google_apis;x86_64" --device "pixel"
avdmanager create avd -n Klijent -k "system-images;android-34;google_apis;x86_64" --device "pixel"
```

---

## 4. Testiranje pojedinih funkcionalnosti

### 4.1. Smještaji u blizini (Google Maps)

Opcija „Near you" na Explore ekranu pita uređaj gdje se nalazi, pa od servera traži sve
smještaje u krugu od 10 km. Ništa u vezi lokacije nije hardkodirano, pa nov emulator prikazuje
praznu listu — AVD po defaultu prijavljuje lokaciju u Mountain View, a seed tamo nema nijedan
smještaj.

Postaviti emulator u Sarajevo, grad sa najviše smještaja u seedu:

```bash
# NAPOMENA: geo fix prima prvo LONGITUDU, pa LATITUDU.
adb emu geo fix 18.4131 43.8563
```

Isto se može i bez adb-a: alatna traka emulatora `...` (Extended controls) → `Location` → unijeti
koordinate → `Set location`.

Nakon toga otvoriti (ili ponovo otvoriti) `Explore` tab — lokacija se čita pri učitavanju
ekrana, pa već otvoren tab zadržava prethodni rezultat dok se ne izgradi ponovo. Ako lista
ostane prazna, provjeriti da je aplikaciji odobrena dozvola za lokaciju.

Koordinate ostalih gradova iz seeda:

| Grad | `adb emu geo fix` |
|---|---|
| Sarajevo | `18.4131 43.8563` |
| Mostar | `17.8078 43.3438` |
| Banja Luka | `17.1910 44.7722` |
| Zagreb | `15.9819 45.8150` |
| Split | `16.4402 43.5081` |
| Dubrovnik | `18.0944 42.6507` |
| Belgrade | `20.4489 44.7866` |
| Budva | `18.8400 42.2911` |
| Ljubljana | `14.5058 46.0569` |
| Salzburg | `13.0550 47.8095` |

Fizičkom uređaju ovo ne treba — tamo aplikacija koristi stvarnu lokaciju.

### 4.2. RabbitMQ (asinhrona obrada)

1. Prijaviti se kao Customer i napraviti rezervaciju.
2. Nakon rezervacije, API šalje poruku na RabbitMQ; Messenger servis je preuzima i u pozadini
   kreira poruku dobrodošlice od vlasnika smještaja (Partner) prema kupcu.
3. Poruka se pojavljuje u razgovoru bez ručnog osvježavanja (SignalR).

Promet na brokeru se može pratiti na http://localhost:15672.

### 4.3. Sistem preporuke

Opis algoritma, ulaznih signala i načina objašnjavanja preporuka nalazi se u zasebnom
dokumentu: [`recommender-dokumentacija.md`](recommender-dokumentacija.md).

---

## 5. Podaci u bazi

Baza se pri svakom pokretanju kreira iz EF migracija (`Database.Migrate()`), a početni podaci
dolaze iz seeda u `server/ebooking-api/Database/Data/Seed/`. Nema `.bak` datoteke niti restore
skripte.

| Entitet | Broj zapisa |
|---|---|
| Države | 6 |
| Gradovi | 10 |
| Partneri | 100 |
| Kupci | 3 000 |
| Smještaji | 250 (svaki sa fotografijama i sadržajima) |
| Rezervacije | 10 000 |
| Recenzije | 8 000 (od toga 1 000 sa komentarom) |

Svaki partner ima najmanje dva smještaja, a rezervacije i recenzije su ravnomjerno raspoređene
po smještajima i kupcima. Avatari korisnika i fotografije smještaja su dio seeda.

---

## 6. Arhitektura i tehnologije

### Serverska strana (.NET 8.0 LTS)

- **ASP.NET Core 8.0** — REST API
- **SignalR** — razmjena poruka u realnom vremenu
- **Entity Framework Core 8.0** — ORM, Code First
- **MSSQL Server 2019** — baza podataka
- **RabbitMQ** — message broker
- **PayPal SDK** — plaćanje (sandbox)
- **ML.NET** — sistem preporuke
- **Docker** — svaki servis u zasebnom kontejneru
- **OAuth 2.0** — Google i Facebook prijava

### Klijentska strana

- **Flutter / Dart**
- **Provider** — upravljanje stanjem
- **SignalR klijent** — poruke u realnom vremenu
- **Google Maps** — lokacije i mapa
- **pdf / printing** — izvještaji u .pdf formatu (desktop)

### CI/CD

- **GitHub Actions** — build i provjere kvaliteta koda
- **Gitleaks** — automatsko skeniranje tajni

---

## 7. Struktura projekta

```
RS2-Seminarski/
├── server/
│   ├── docker-compose.yaml           # orkestracija svih servisa
│   ├── .env-tajne.zip                # konfiguracija (zaštićena lozinkom)
│   ├── .env.example                  # predložak konfiguracije
│   └── ebooking-api/
│       ├── API/                      # glavni REST API servis
│       ├── Messenger/                # SignalR servis (RabbitMQ consumer)
│       ├── PaymentApp/               # servis za plaćanje
│       ├── Database/                 # EF Core kontekst, migracije i seed
│       ├── Models/                   # domenski modeli i DTO objekti
│       └── Authentication/           # JWT i autentifikacija
├── client/
│   ├── desktop/                      # Flutter desktop (Windows) aplikacija
│   └── mobile/                       # Flutter mobilna (Android) aplikacija
├── recommender-dokumentacija.md      # opis sistema preporuke
└── .github/workflows/                # CI/CD
```

---

## 8. Sigurnost

- **PBKDF2-HMAC-SHA256**, so po korisniku i 210 000 iteracija — lozinke se nikada ne čuvaju u
  čitljivom obliku
- **JWT** sa validacijom potpisa; odjava poništava token na serveru
- **Role-based autorizacija** na admin endpointima
- **Nema tajni u izvornom kodu** — sve kroz `.env` i `--dart-define`
- **`.gitignore`** sprječava commitovanje `.env`, `local.properties` i keystore datoteka
- **ProGuard/R8** — obfuskacija Android koda
- **Gitleaks** — automatsko skeniranje tajni u CI-ju
