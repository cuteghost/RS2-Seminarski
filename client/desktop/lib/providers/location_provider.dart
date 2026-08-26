import 'package:flutter/foundation.dart';

import 'package:ebooking_desktop/models/city.dart';
import 'package:ebooking_desktop/models/country.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/location_service.dart';

/// Stanje referentnih podataka lokacije (države + gradovi).
///
/// NOVO — ranije desktop nije imao provider za lokacije; `ManageCountryPage`
/// je zvao `static CountryHttpService.*` direktno iz `setState`-a, pa se
/// lista država nije mogla dijeliti sa ostatkom aplikacije (npr. dropdown
/// filterom na ekranu smještaja).
class LocationProvider with ChangeNotifier {
  final LocationService locationService;

  LocationProvider({required this.locationService});

  List<Country> _countries = [];
  List<City> _cities = [];

  bool _isLoadingCountries = false;
  bool _isLoadingCities = false;
  String? _countriesError;
  String? _citiesError;

  String _countryQuery = '';
  String _cityQuery = '';
  String? _cityCountryFilter;

  List<Country> get countries => List.unmodifiable(_countries);
  List<City> get cities => List.unmodifiable(_cities);

  bool get isLoadingCountries => _isLoadingCountries;
  bool get isLoadingCities => _isLoadingCities;
  String? get countriesError => _countriesError;
  String? get citiesError => _citiesError;

  String get countryQuery => _countryQuery;
  String get cityQuery => _cityQuery;
  String? get cityCountryFilter => _cityCountryFilter;

  // ── Učitavanje ──────────────────────────────────────────────────────────

  Future<void> loadCountries() async {
    _isLoadingCountries = true;
    _countriesError = null;
    notifyListeners();

    try {
      final page = await locationService.getCountries();
      _countries = page.items..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _countriesError = ApiResponseHandler.describe(e);
    } finally {
      _isLoadingCountries = false;
      notifyListeners();
    }
  }

  Future<void> loadCities() async {
    _isLoadingCities = true;
    _citiesError = null;
    notifyListeners();

    try {
      _cities = await locationService.getCities()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _citiesError = ApiResponseHandler.describe(e);
    } finally {
      _isLoadingCities = false;
      notifyListeners();
    }
  }

  /// Oba resursa paralelno — zovemo ga pri ulasku na ekran Lokacije.
  Future<void> loadAll() =>
      Future.wait([loadCountries(), loadCities()]);

  // ── Write operacije ─────────────────────────────────────────────────────
  //
  // Sve tri vraćaju poruku sa servera i propuštaju `ApiException` naviše —
  // UI je hvata i prikazuje. Namjerno NEMA `try/catch` koji guta grešku
  // (to je bio bug u staroj `CountryHttpService.editCountry`).

  Future<String> addCountry(String name) async {
    final message = await locationService.addCountry(name.trim());
    await loadCountries();
    return message;
  }

  Future<String> updateCountry({
    required String id,
    required String name,
  }) async {
    final message =
        await locationService.updateCountry(id: id, name: name.trim());
    await loadCountries();
    return message;
  }

  Future<String> deleteCountry(String id) async {
    final message = await locationService.deleteCountry(id);
    await Future.wait([loadCountries(), loadCities()]);
    return message;
  }

  Future<String> addCity({
    required String name,
    required String countryId,
  }) async {
    final message = await locationService.addCity(
      name: name.trim(),
      countryId: countryId,
    );
    await loadCities();
    return message;
  }

  // ── Filteri ─────────────────────────────────────────────────────────────

  void setCountryQuery(String value) {
    _countryQuery = value;
    notifyListeners();
  }

  void setCityQuery(String value) {
    _cityQuery = value;
    notifyListeners();
  }

  void setCityCountryFilter(String? countryName) {
    _cityCountryFilter = countryName;
    notifyListeners();
  }

  // ── Izvedeni podaci ─────────────────────────────────────────────────────

  List<Country> get filteredCountries {
    final query = _countryQuery.trim().toLowerCase();
    if (query.isEmpty) return countries;
    return _countries
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }

  List<City> get filteredCities {
    final query = _cityQuery.trim().toLowerCase();
    return _cities.where((c) {
      if (query.isNotEmpty && !c.name.toLowerCase().contains(query)) {
        return false;
      }
      if (_cityCountryFilter != null && c.countryName != _cityCountryFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Koliko gradova pripada datoj državi — kolona "Gradovi" u tabeli država.
  ///
  /// Računa se lokalno jer `CountryGET` nema `cityCount`. Kad se `City`
  /// entitet refaktoriše, ovo treba doći sa servera jednim `GroupBy` upitom
  /// (Upute 8.2) umjesto da klijent broji.
  int cityCountFor(Country country) =>
      _cities.where((c) => c.countryName == country.name).length;

  /// Da li se država smije brisati.
  ///
  /// Upute 6: "Nedostupne akcije moraju imati onemogućeno (disabled) stanje uz
  /// objašnjenje razloga nedostupnosti." Ovo je klijentsko predviđanje istog
  /// pravila koje backend `CountryService.DeleteCountry` provodi — server i
  /// dalje ostaje jedini autoritet.
  String? deleteBlockedReason(Country country) {
    final count = cityCountFor(country);
    if (count == 0) return null;
    return 'Brisanje nije moguće: državi je dodijeljeno '
        '$count ${count == 1 ? 'grad' : 'gradova'}. '
        'Prvo uklonite ili premjestite te gradove.';
  }
}
