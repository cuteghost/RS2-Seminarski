import 'package:flutter/foundation.dart';

import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/models/reservation_model.dart';
import 'package:ebooking_desktop/services/admin_service.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';

/// Stanje administratorskih pregleda: smještaji, korisnici, rezervacije.
///
/// Filtriranje i pretraga se rade OVDJE (a ne u widgetima) da bi ekrani ostali
/// glupi i da bi ista logika mogla poslužiti i izvještajima.
class AdminProvider with ChangeNotifier {
  final AdminService adminService;

  AdminProvider({required this.adminService});

  List<AccommodationGET> _accommodations = [];
  List<Profile> _profiles = [];
  List<ReservationGET> _reservations = [];

  bool _isLoading = false;
  String? _error;

  // ── Filteri: smještaji ──────────────────────────────────────────────────
  String _propertyQuery = '';
  String? _propertyCityFilter;
  TypesOfAccommodation? _propertyTypeFilter;
  bool? _propertyStatusFilter;

  // ── Filteri: korisnici ──────────────────────────────────────────────────
  String _userQuery = '';
  bool? _userStatusFilter;

  List<AccommodationGET> get accommodations => List.unmodifiable(_accommodations);
  List<Profile> get profiles => List.unmodifiable(_profiles);
  List<ReservationGET> get reservations => List.unmodifiable(_reservations);

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _accommodations.isNotEmpty || _profiles.isNotEmpty;

  String get propertyQuery => _propertyQuery;
  String? get propertyCityFilter => _propertyCityFilter;
  TypesOfAccommodation? get propertyTypeFilter => _propertyTypeFilter;
  bool? get propertyStatusFilter => _propertyStatusFilter;
  String get userQuery => _userQuery;
  bool? get userStatusFilter => _userStatusFilter;

  // ── Učitavanje ──────────────────────────────────────────────────────────

  /// Učitava sve administratorske podatke odjednom.
  ///
  /// Tri poziva su nezavisna pa idu paralelno kroz `Future.wait`
  /// (Upute Dodatak A.2 — serijske HTTP pozive koji se mogu paralelizovati
  /// treba smjestiti u `Future.wait`). Ranije su bili tri uzastopna `await`-a
  /// u `main.dart` i `login.dart`, što je login činilo osjetno sporijim.
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        adminService.getAccommodations(),
        adminService.getProfiles(),
        adminService.getReservations(),
      ]);
      _accommodations = results[0] as List<AccommodationGET>;
      _profiles = results[1] as List<Profile>;
      _reservations = results[2] as List<ReservationGET>;
    } catch (e) {
      _error = ApiResponseHandler.describe(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAccommodations() async {
    _accommodations = await adminService.getAccommodations();
    notifyListeners();
  }

  Future<void> getProfiles() async {
    _profiles = await adminService.getProfiles();
    notifyListeners();
  }

  Future<void> getReservations() async {
    _reservations = await adminService.getReservations();
    notifyListeners();
  }

  // ── Akcije ──────────────────────────────────────────────────────────────

  /// Deaktivira korisnički nalog. Vraća poruku sa servera.
  Future<String> deleteUser(String userId) async {
    final message = await adminService.deleteUser(userId);
    // Optimistično uklanjanje bi sakrilo neuspjeh, pa radije osvježimo listu.
    _profiles = await adminService.getProfiles();
    notifyListeners();
    return message;
  }

  // ── Filteri ─────────────────────────────────────────────────────────────

  void setPropertyQuery(String value) {
    _propertyQuery = value;
    notifyListeners();
  }

  void setPropertyCityFilter(String? city) {
    _propertyCityFilter = city;
    notifyListeners();
  }

  void setPropertyTypeFilter(TypesOfAccommodation? type) {
    _propertyTypeFilter = type;
    notifyListeners();
  }

  void setPropertyStatusFilter(bool? status) {
    _propertyStatusFilter = status;
    notifyListeners();
  }

  void clearPropertyFilters() {
    _propertyQuery = '';
    _propertyCityFilter = null;
    _propertyTypeFilter = null;
    _propertyStatusFilter = null;
    notifyListeners();
  }

  void setUserQuery(String value) {
    _userQuery = value;
    notifyListeners();
  }

  void setUserStatusFilter(bool? status) {
    _userStatusFilter = status;
    notifyListeners();
  }

  // ── Izvedeni podaci ─────────────────────────────────────────────────────

  /// Gradovi koji se stvarno pojavljuju u smještajima — za dropdown filter.
  /// Upute 6: padajuće liste se pune iz podataka, nikad hardkodirano.
  List<String> get availableCities {
    final cities = _accommodations
        .map((a) => a.location.cityName)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return cities;
  }

  List<AccommodationGET> get filteredAccommodations {
    final query = _propertyQuery.trim().toLowerCase();
    return _accommodations.where((a) {
      if (query.isNotEmpty) {
        final haystack =
            '${a.name} ${a.location.address} ${a.location.placeLabel}'
                .toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      if (_propertyCityFilter != null &&
          a.location.cityName != _propertyCityFilter) {
        return false;
      }
      if (_propertyTypeFilter != null &&
          a.typeOfAccommodation != _propertyTypeFilter) {
        return false;
      }
      if (_propertyStatusFilter != null && a.status != _propertyStatusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Profile> get filteredProfiles {
    final query = _userQuery.trim().toLowerCase();
    return _profiles.where((p) {
      if (query.isNotEmpty) {
        final haystack =
            '${p.fullName} ${p.displayName} ${p.emailAddress}'.toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      if (_userStatusFilter != null && p.isActive != _userStatusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  /// BUGFIX: ranije su `getHighestRent()` / `getLowestRent()` radili
  /// `_accommodations.sort(...)` pa `.first` — dvije greške odjednom:
  ///   1. `.first` na praznoj listi baca `StateError` i ruši cijeli dashboard
  ///      čim baza nema nijedan smještaj;
  ///   2. `sort` je mutirao listu koju UI istovremeno prikazuje, pa se
  ///      redoslijed u tabeli mijenjao kao nuspojava otvaranja dashboarda.
  /// Sada: nullable povratna vrijednost, bez mutiranja izvorne liste.
  AccommodationGET? get highestRent {
    if (_accommodations.isEmpty) return null;
    return _accommodations
        .reduce((a, b) => b.pricePerNight > a.pricePerNight ? b : a);
  }

  AccommodationGET? get lowestRent {
    if (_accommodations.isEmpty) return null;
    return _accommodations
        .reduce((a, b) => b.pricePerNight < a.pricePerNight ? b : a);
  }

  int get activeAccommodationCount =>
      _accommodations.where((a) => a.status).length;

  int get activeUserCount => _profiles.where((p) => p.isActive).length;

  /// Broj rezervacija po danu za zadnjih [days] dana — ulaz za dashboard graf.
  ///
  /// Ranije se ovo računalo unutar `build()` metode dashboarda, ugniježđenom
  /// petljom 30 × N rezervacija, na svaki rebuild. Sada je u provideru i
  /// računa se jednom po pozivu.
  List<({String label, num value})> reservationsPerDay({int days = 30}) {
    final today = DateTime.now();
    final buckets = <({String label, num value})>[];

    for (var i = days - 1; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));

      final count = _reservations
          .where((r) => r.startDate.isBefore(next) && r.endDate.isAfter(day))
          .length;

      buckets.add((label: '${day.day}', value: count));
    }
    return buckets;
  }
}
