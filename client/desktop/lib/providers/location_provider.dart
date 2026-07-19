import 'package:flutter/foundation.dart';

import 'package:ebooking_desktop/models/city.dart';
import 'package:ebooking_desktop/models/country.dart';
import 'package:ebooking_desktop/models/location_model.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/location_service.dart';

/// Stanje referentnih podataka lokacije (države + gradovi), dijeljeno sa
/// ostatkom aplikacije (npr. dropdown filterom na ekranu smještaja).
class LocationProvider with ChangeNotifier {
  final LocationService locationService;

  LocationProvider({required this.locationService});

  List<Country> _countries = [];
  List<City> _cities = [];
  List<Location> _locations = [];

  bool _isLoadingCountries = false;
  bool _isLoadingCities = false;
  String? _countriesError;
  String? _citiesError;

  String _countryQuery = '';
  String _cityQuery = '';
  String? _cityCountryFilter;
  String _locationQuery = '';
  String? _locationCityFilter;
  bool _isLoadingLocations = false;
  String? _locationsError;

  List<Country> get countries => List.unmodifiable(_countries);
  List<City> get cities => List.unmodifiable(_cities);
  List<Location> get locations => List.unmodifiable(_locations);

  bool get isLoadingCountries => _isLoadingCountries;
  bool get isLoadingCities => _isLoadingCities;
  String? get countriesError => _countriesError;
  String? get citiesError => _citiesError;

  String get countryQuery => _countryQuery;
  String get cityQuery => _cityQuery;
  String get locationQuery => _locationQuery;
  String? get locationCityFilter => _locationCityFilter;
  bool get isLoadingLocations => _isLoadingLocations;
  String? get locationsError => _locationsError;
  String? get cityCountryFilter => _cityCountryFilter;

  // ── Učitavanje ──────────────────────────────────────────────────────────

  Future<void> loadCountries() async {
    _isLoadingCountries = true;
    _countriesError = null;
    notifyListeners();

    try {
      _countries = await locationService.getCountries()
        ..sort((a, b) => a.name.compareTo(b.name));
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

  Future<void> loadAll() =>
      Future.wait([loadCountries(), loadCities(), loadLocations()]);

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

  Future<String> updateCity({
    required String id,
    required String name,
    required String countryId,
  }) async {
    final message = await locationService.updateCity(
      id: id,
      name: name.trim(),
      countryId: countryId,
    );
    await loadCities();
    return message;
  }

  Future<void> loadLocations() async {
    _isLoadingLocations = true;
    _locationsError = null;
    notifyListeners();

    try {
      _locations = await locationService.getLocations()
        ..sort((a, b) => a.address.compareTo(b.address));
    } catch (e) {
      _locationsError = ApiResponseHandler.describe(e);
    } finally {
      _isLoadingLocations = false;
      notifyListeners();
    }
  }

  Future<String> addLocation({
    required String address,
    required double latitude,
    required double longitude,
    required String cityId,
  }) async {
    final message = await locationService.addLocation(
      address: address.trim(),
      latitude: latitude,
      longitude: longitude,
      cityId: cityId,
    );
    await loadLocations();
    return message;
  }

  Future<String> updateLocation({
    required String id,
    required String address,
    required double latitude,
    required double longitude,
    required String cityId,
  }) async {
    final message = await locationService.updateLocation(
      id: id,
      address: address.trim(),
      latitude: latitude,
      longitude: longitude,
      cityId: cityId,
    );
    await loadLocations();
    return message;
  }

  Future<String> deleteLocation(String id) async {
    final message = await locationService.deleteLocation(id);
    await loadLocations();
    return message;
  }

  List<Location> get filteredLocations {
    final query = _locationQuery.trim().toLowerCase();
    return _locations.where((l) {
      if (query.isNotEmpty && !l.address.toLowerCase().contains(query)) {
        return false;
      }
      if (_locationCityFilter != null && l.cityId != _locationCityFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<String> deleteCity(String id) async {
    final message = await locationService.deleteCity(id);
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

  void setLocationQuery(String value) {
    _locationQuery = value;
    notifyListeners();
  }

  void setLocationCityFilter(String? cityId) {
    _locationCityFilter = cityId;
    notifyListeners();
  }

  void setCityCountryFilter(String? countryId) {
    _cityCountryFilter = countryId;
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
      if (_cityCountryFilter != null && c.countryId != _cityCountryFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Koliko gradova pripada datoj državi — kolona "Gradovi" u tabeli država.
  ///
  /// Računa se lokalno jer `CountryGET` nema `cityCount`; poredi se po `countryId`
  /// pa je tačno i kad dvije države nose isti naziv.
  int cityCountFor(Country country) =>
      _cities.where((c) => c.countryId == country.id).length;

  /// Da li se država smije brisati. Ovo je klijentsko predviđanje istog pravila
  /// koje backend `CountryService.DeleteCountry` provodi — server i dalje ostaje
  /// jedini autoritet.
  String? deleteBlockedReason(Country country) {
    final count = cityCountFor(country);
    if (count == 0) return null;
    return 'Cannot delete: this country has '
        '$count ${count == 1 ? 'city' : 'cities'} assigned to it. '
        'Remove or move those cities first.';
  }
}
