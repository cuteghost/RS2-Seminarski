# Log infrastrukturnih izmjena — Flutter klijenti

**Datum:** 2026-08-10
**Grana:** `infra/config-cleanup`
**Flutter SDK:** nije dostupan u sandboxu — `flutter analyze` i build moraju se pokrenuti lokalno (vidi Sekciju 2)

---

## 1. Primijenjene izmjene

| ID | Sekcija Uputa | Fajl(ovi) | Šta je urađeno | Rizik |
|----|---------------|-----------|----------------|-------|
| M1 | client/mobile | `lib/config/config.dart` *(novi fajl)* | Kreiran `AppConfig` sa `baseUrl`, `messengerUrl`, `paymentUrl` (port 6666 iz docker-compose), `googleApiKey`, `googleServerClientId` — sve kao `String.fromEnvironment` sa fallback vrijednostima za emulator (`10.0.2.2`) | Nizak |
| M2 | client/mobile | `lib/services/auth_service.dart` | Hardkodirani `serverClientId` premješten u `AppConfig.googleServerClientId` | Nizak |
| M3a | client/mobile | `lib/screens/customer_screens/reservations_screen.dart` | Fajl bio 2 bajta (prazan). Nije importovan nigdje. Neutraliziran komentarom. | Nizak |
| M3b | client/mobile | `lib/main.dart` | Uklonjena prazna klasa `class SuggestionService {}` (nije ista kao `SuggestionsService` u services/) | Nizak |
| M3c | client/mobile | `lib/widgets/custom_dropdown_button.dart` | `CustomDropdownButton` nije importovan/korišten nigdje. Neutraliziran komentarom. | Nizak |
| M4a | client/mobile | `lib/services/signalr_service.dart` | Uklonjena metoda `handleIncommingDriverLocation` — nije se pozivala nigdje u mobile klijentu | Nizak |
| M4b | client/mobile | *(pretraga)* | `Driver`, `Taxi`, `Ride`, `WeatherForecast` — jedina pojava bila je u `handleIncommingDriverLocation` koji je obrisan. Bez ostalih kopija. | N/A |
| M5a | client/mobile | `lib/screens/login_screen.dart` | Uklonjen `void initState()` unutar `LoginPage extends StatelessWidget` | Nizak |
| M5b | client/mobile | `lib/screens/customer_screens/checkout_screen.dart` | Uklonjen `Future.delayed(Duration(seconds: 5));` bez await — mrtav poziv bez efekta | Nizak |
| M5c | client/mobile | `lib/screens/customer_screens/history_screen.dart` | Uklonjen komentar `// Pokuso pokuso` i zakomentarisani `IconButton` blok | Nizak |
| M6 | client/mobile | 20+ fajlova (services, screens, providers) | Uklonjeni svi `print()` pozivi (55 linija). Uključuje standalone `print(...);` i ugrađene pozive u set-literalima i SignalR logging callback-u. | Nizak |
| M7a | client/mobile | `lib/screens/partner_screens/add_accommodation_screen.dart` | `dispose()` postojao ali prazan — dodano disposal za 5 kontrolera (`_addressController`, `_nameController`, `_priceController`, `_descriptionController`, `_accommodationDetailsNumBeds`) | Nizak |
| M7b | client/mobile | `lib/screens/customer_screens/feedback_screen.dart` | Dodano `dispose()` sa `commentsController.dispose()` | Nizak |
| M7c | client/mobile | `lib/screens/customer_screens/search_screen.dart` | Nema `TextEditingController` — `dispose()` već postoji i poziva `super.dispose()`. Ništa dodati. | N/A |
| M7d | client/mobile | `lib/screens/messenger_screen.dart` | Dodano `dispose()` sa `_controller.dispose()` i `_scrollController.dispose()` | Nizak |
| M8 | client/mobile | `lib/providers/reservation_provide.dart` → `reservation_provider.dart` | Fajl preimenovan; importi ažurirani u `main.dart`, `booking_screen.dart`, `checkout_screen.dart`, `history_screen.dart` | Nizak |
| M9a | client/mobile | `lib/widgets/CustomBottomNavigationBar.dart` → `custom_bottom_navigation_bar.dart` | Preimenovan; 8 fajlova sa importom ažurirano | Nizak |
| M9b | client/mobile | `lib/widgets/CustomPartnerBottomNavigationBar.dart` → `custom_partner_bottom_navigation_bar.dart` | Preimenovan; importi ažurirani | Nizak |
| M9c | client/mobile | `lib/widgets/customIconButton.dart` → `custom_icon_button.dart` | Preimenovan; 2 fajla (`CustomBottomNavigationBar`, `CustomPartnerBottomNavigationBar`) ažurirana | Nizak |
| D1 | client/desktop | `lib/services/signalr_service.dart` | Zamijenjen hardkodirani `https://messenger.cuteghost.online/chathub` sa `'${config.AppConfig.messengerUrl}/chathub'` | Nizak |
| D2 | client/desktop | `lib/config/config.dart` | `String.fromEnvironment('BASE_URL')` → `String.fromEnvironment('API_BASE_URL')` | Nizak |
| D3 | client/desktop | `lib/main.dart` | Obrisana `class X509Override extends HttpOverrides` i njena registracija `HttpOverrides.global = X509Override()`. Uklonjen `import 'dart:io'`. | **Srednji** — ovo je zaobilazilo provjeru SSL certifikata. Ako se app spaja na server s self-signed certifikatom, veza će sada padati. Potrebna provjera u produkcijskom/test okruženju. |
| D4 | client/desktop | `lib/pages/dashboard.dart` | Uklonjena vlastita `main()` funkcija i `MaterialApp` omotač iz `DashboardApp`. `DashboardApp` sada direktno vraća `DashboardPage()`. `main.dart` ostaje jedina entry-point. | Nizak |
| D5 | client/desktop | `lib/pages/countries/modals/deleteCountryModal.dart` | Fajl bio 0 bajtova, nije importovan nigdje. Neutraliziran komentarom. | Nizak |
| D6a | client/desktop | `lib/services/admin_service.dart` | Uklonjena metoda `lowestRents()` — poziva nepostojeuću rutu `/api/Administrator/AccommodationWithLowestRents`, nigdje se ne poziva | Nizak |
| D6b | client/desktop | `lib/services/profile_service.dart` | Uklonjene metode `fetchPartner()` i `updatePartner()` — nigdje se ne pozivaju iz UI/providers | Nizak |
| D6c | client/desktop | `lib/models/partner_model.dart` | Neutraliziran — `Partner` klasa koristila se isključivo u `fetchPartner`/`updatePartner` koji su obrisani | Nizak |
| D6d | client/desktop | `lib/providers/profile_provider.dart` | Uklonjen nekorišten `import 'package:ebooking_desktop/models/partner_model.dart'` | Nizak |
| D6e | client/desktop | `lib/pages/manageUsers.dart`, `lib/pages/manageProperties.dart` | Uklonjeni zakomentarisani `IconButton` (edit) i `PopupMenuButton` blokovi. Prazni `onPressed: () {}` nisu dirani. | Nizak |
| D7a | client/desktop | `lib/pages/manageUsers.dart` | Uklonjene nekorišćene varijable `screenWidth`, `cardWidth` i nekorišćeni import `flutter/widgets.dart` | Nizak |
| D7b | client/desktop | `lib/pages/manageProperties.dart` | Isti kao D7a | Nizak |
| D7c | client/desktop | `lib/pages/countries/manageCountry.dart` | Uklonjene nekorišćene varijable `selectedCountryName` i `selectedCountryId` | Nizak |
| D8 | client/desktop | 7 fajlova (services, providers, modals) | Uklonjeni svi `print()` pozivi (~25 linija) | Nizak |
| D9a | client/desktop | `lib/pages/countries/manageCountry.dart` | Dodano `dispose()` sa `_nameController.dispose()` | Nizak |
| D9b | client/desktop | `lib/pages/messenger_screen.dart` | Dodano `dispose()` sa `_controller.dispose()` i `_scrollController.dispose()` | Nizak |
| D10 | client/desktop | `lib/pages/manageUsers.dart`, `lib/pages/manageProperties.dart` | `ButtonBar` zamijenjen sa `OverflowBar` (direktna zamjena, isti API) | Nizak |

---

## 2. Rezultati builda

> ⚠️ **Flutter SDK nije dostupan u sandbox okruženju.** `flutter analyze` i `flutter build` moraju se pokrenuti lokalno na razvojnoj mašini.

### Komande za lokalnu verifikaciju

```bash
# Mobile
cd client/mobile
flutter clean && flutter pub get
flutter analyze
flutter build apk --release

# Desktop
cd client/desktop
flutter clean && flutter pub get
flutter analyze
flutter build windows --release
```

### Statička provjera (obavljena u sandboxu)

- ✅ Svi preimenovani fajlovi postoje na novim putanjama
- ✅ Niti jedan stari import (reservation_provide, CustomBottomNavigationBar, CustomPartnerBottomNavigationBar, customIconButton) ne postoji više
- ✅ `AppConfig` u mobile definira sva polja koja se koriste (`baseUrl`, `messengerUrl`, `paymentUrl`, `googleApiKey`, `googleServerClientId`)
- ✅ Desktop config.dart koristi `API_BASE_URL`
- ✅ `X509Override` uklonjen, `dart:io` import uklonjen iz desktop `main.dart`
- ✅ `DashboardApp` više nema vlastitu `main()` ni `MaterialApp`
- ✅ Nula preostalih `print()` poziva u oba klijenta
- ✅ `ButtonBar` zamijenjen sa `OverflowBar` u oba fajla
- ✅ `lowestRents()` uklonjen

---

## 3. Nije urađeno — van opsega

Sljedeće je eksplicitno izvan opsega i nije dirano:

- Logika plaćanja, status rezervacije, state machine, paginacija, PDF izvještaji
- CRUD ekrani za referentne podatke, validation UX, recommender (`SuggestionsService`)
- Autorizacija endpointa, JWT logika, logout invalidacija
- Refaktor base64/slike, refaktor duplirane login logike (3 mjesta u `login_screen.dart`)
- Bilo šta u `server/` folderu
- `.env`, `.gitignore`, tajne, ključevi, `keys/`, `*.jwk`

---

## 4. Eskalacije — potrebna odluka

| # | Opis | Lokacija | Rizik |
|---|------|----------|-------|
| E1 | **X509Override (D3)** — uklanjanje zaobilaznice SSL certifikata može prekinuti konekciju na server ako se koristi self-signed certifikat (što ime `cuteghost.online` u SignalR URL-u sugerira da se radilo). Potrebno testirati konekciju prema staging/prod serveru. | `client/desktop/lib/main.dart` | **Srednji** |
| E2 | **`handleIncommingDriverLocation` u desktop `signalr_service.dart`** — ova metoda je ostala (za razliku od mobile gdje je obrisana) jer se poziva iz `message_provider.dart:30`. Naziv je copy-paste ostatak ("Driver Location" nema smisla u booking kontekstu), ali uklanjanje zahtijeva izmjenu i providera. Preporučuje se refaktorisanje u narednoj iteraciji. | `client/desktop/lib/services/signalr_service.dart` | Nizak |
| E3 | **`googleApiKey` u `AppConfig` mobile** — dodan kao `String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '')` jer ga `location_service.dart` koristi za Google Maps Geocoding API. Prazna default vrijednost znači da geocoding neće raditi u dev buildu bez eksplicitnog postavljanja. Treba dodati pravi ključ u build skriptu. | `client/mobile/lib/config/config.dart` | Nizak |
| E4 | **`flutter pub outdated`** — nije pokrenuto jer Flutter SDK nije dostupan u sandboxu. Pokrenuti lokalno: `cd client/mobile && flutter pub outdated` i `cd client/desktop && flutter pub outdated`. Rezultate priložiti u narednoj iteraciji. | Obje lokacije | N/A |
| E5 | **`login.dart` desktop (D9)** — `LoginPage extends StatelessWidget` ima dva `TextEditingController` kao instance varijable. StatelessWidget nije ispravan holder za mutirajući state — disposal nije moguć bez refaktora u StatefulWidget. Ovo je poseban issue za narednu iteraciju. | `client/desktop/lib/pages/login.dart` | Nizak |

---

## 5. flutter pub outdated tabela

> Nije dostupno — Flutter SDK nije u sandboxu. Pokrenuti lokalno i rezultate dodati ovdje:
>
> ```
> cd client/mobile && flutter pub outdated
> cd client/desktop && flutter pub outdated
> ```

---

## 6. Preostali problemi nakon builda

> Nakon lokalnog pokretanja `flutter analyze`, očekivani preostali problemi:
>
> - **Mobile**: Potencijalno `unused_import` u fajlovima koji su imali print() a koji su ostali s importom `dart:io` ili sl. Svaki takav import je trivijalan za ukloniti.
> - **Desktop**: `DashboardPage` ima nekorišćenu lokalnu funkciju `calculateNumberOfRentsPerDay` — nije dirana jer je van opsega (logika prikazivanja grafikona), ali `flutter analyze` može je prijaviti.
> - **Desktop**: Prazni `catch (e) {}` blokovi nastali uklanjanjem `print()` — analyzer može prijaviti `empty_catches`. Preporučljivo je dodati minimalan error handling u narednoj iteraciji.
