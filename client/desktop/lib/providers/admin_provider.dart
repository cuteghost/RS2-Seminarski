import 'package:flutter/foundation.dart';

import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/models/accommodation_review.dart';
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
  String? _imageToken;
  String _signedInAdministratorId = '';
  List<ReservationGET> _reservations = [];

  bool _isLoading = false;
  String? _error;

  List<Profile> _users = [];
  int _usersPage = 1;
  int _usersPageSize = 20;
  int _usersTotalCount = 0;
  int _usersTotalPages = 1;
  bool _usersLoading = false;
  String? _usersError;

  int _userTotalCount = 0;
  int _userActiveCount = 0;

  List<ReservationGET> _reservationsList = [];
  int _reservationsPage = 1;
  int _reservationsPageSize = 20;
  int _reservationsTotalCount = 0;
  int _reservationsTotalPages = 1;
  bool _reservationsLoading = false;
  String? _reservationsError;

  List<AccommodationGET> _properties = [];
  int _propertiesPage = 1;
  int _propertiesPageSize = 20;
  int _propertiesTotalCount = 0;
  int _propertiesTotalPages = 1;
  bool _propertiesLoading = false;
  String? _propertiesError;

  // ── Filteri: smještaji ──────────────────────────────────────────────────
  // `_propertyCityFilter` nosi `cityId`, ne naziv grada — server filtrira po
  // identifikatoru.
  String _propertyQuery = '';
  String? _propertyCityFilter;
  String? _propertyTypeFilter;
  bool? _propertyStatusFilter;

  // ── Filteri: rezervacije ────────────────────────────────────────────────
  String _reservationQuery = '';
  ReservationStatus? _reservationStatusFilter;
  DateTime? _reservationStart;
  DateTime? _reservationEnd;

  // ── Filteri: korisnici ──────────────────────────────────────────────────
  String _userQuery = '';
  bool? _userStatusFilter;
  UserRole? _userRoleFilter;

  List<AccommodationGET> get accommodations => List.unmodifiable(_accommodations);
  List<ReservationGET> get reservations => List.unmodifiable(_reservations);

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _accommodations.isNotEmpty || _users.isNotEmpty;

  String? get imageToken => _imageToken;

  /// Nalog pod kojim je administrator prijavljen — brisanje i deaktivacija
  /// vlastitog naloga su na serveru zabranjeni, pa se ni ne nude.
  String get signedInAdministratorId => _signedInAdministratorId;

  List<AccommodationGET> get properties => List.unmodifiable(_properties);
  int get propertiesPage => _propertiesPage;
  int get propertiesPageSize => _propertiesPageSize;
  int get propertiesTotalCount => _propertiesTotalCount;
  int get propertiesTotalPages => _propertiesTotalPages;
  bool get propertiesLoading => _propertiesLoading;
  String? get propertiesError => _propertiesError;

  String get propertyQuery => _propertyQuery;
  String? get propertyCityFilter => _propertyCityFilter;
  String? get propertyTypeFilter => _propertyTypeFilter;
  bool? get propertyStatusFilter => _propertyStatusFilter;
  String get reservationQuery => _reservationQuery;
  ReservationStatus? get reservationStatusFilter => _reservationStatusFilter;
  DateTime? get reservationStart => _reservationStart;
  DateTime? get reservationEnd => _reservationEnd;

  List<ReservationGET> get reservationsList => List.unmodifiable(_reservationsList);
  int get reservationsPage => _reservationsPage;
  int get reservationsPageSize => _reservationsPageSize;
  int get reservationsTotalCount => _reservationsTotalCount;
  int get reservationsTotalPages => _reservationsTotalPages;
  bool get reservationsLoading => _reservationsLoading;
  String? get reservationsError => _reservationsError;

  List<Profile> get users => List.unmodifiable(_users);
  int get usersPage => _usersPage;
  int get usersPageSize => _usersPageSize;
  int get usersTotalCount => _usersTotalCount;
  int get usersTotalPages => _usersTotalPages;
  bool get usersLoading => _usersLoading;
  String? get usersError => _usersError;

  int get userTotalCount => _userTotalCount;
  int get userActiveCount => _userActiveCount;

  String get userQuery => _userQuery;
  bool? get userStatusFilter => _userStatusFilter;
  UserRole? get userRoleFilter => _userRoleFilter;

  // ── Učitavanje ──────────────────────────────────────────────────────────

  /// Učitava sve administratorske podatke odjednom.
  ///
  /// Tri poziva su nezavisna pa idu paralelno kroz `Future.wait` umjesto tri
  /// uzastopna `await`-a.
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _imageToken = await adminService.currentToken();
      final results = await Future.wait([
        adminService.getAccommodations(),
        adminService.getReservations(),
      ]);
      _accommodations = results[0] as List<AccommodationGET>;
      _reservations = results[1] as List<ReservationGET>;
      await Future.wait([
        loadUsers(resetPage: true),
        loadUserCounts(),
        loadSignedInAdministrator(),
        loadProperties(resetPage: true),
        loadReservations(resetPage: true),
      ]);
    } catch (e) {
      _error = ApiResponseHandler.describe(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAccommodations() async {
    _imageToken = await adminService.currentToken();
    _accommodations = await adminService.getAccommodations();
    notifyListeners();
  }

  Future<void> loadProperties({bool resetPage = false}) async {
    if (resetPage) _propertiesPage = 1;
    _propertiesLoading = true;
    _propertiesError = null;
    notifyListeners();

    try {
      final result = await adminService.getAccommodationsPage(
        search: _propertyQuery,
        cityId: _propertyCityFilter,
        accommodationTypeId: _propertyTypeFilter,
        status: _propertyStatusFilter,
        page: _propertiesPage,
        pageSize: _propertiesPageSize,
      );
      _imageToken ??= await adminService.currentToken();
      _properties = result.items;
      _propertiesTotalCount = result.totalCount;
      _propertiesTotalPages = result.totalPages < 1 ? 1 : result.totalPages;
    } catch (e) {
      _propertiesError = ApiResponseHandler.describe(e);
    } finally {
      _propertiesLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPropertiesPage(int page) async {
    if (page < 1 || page > _propertiesTotalPages || page == _propertiesPage) return;
    _propertiesPage = page;
    await loadProperties();
  }

  Future<void> setPropertiesPageSize(int pageSize) async {
    if (pageSize == _propertiesPageSize) return;
    _propertiesPageSize = pageSize;
    await loadProperties(resetPage: true);
  }

  Future<void> loadSignedInAdministrator() async {
    try {
      final signedIn = await adminService.getSignedInAdministrator();
      _signedInAdministratorId = signedIn?.id ?? '';
    } on ApiException {
      _signedInAdministratorId = '';
    }
    notifyListeners();
  }

  /// Ukupan broj registrovanih i aktivnih korisnika, nezavisno od trenutne
  /// stranice i filtera na ekranu *Korisnici* — koristi ih i taj ekran (u
  /// podnaslovu) i dashboard.
  Future<void> loadUserCounts() async {
    final results = await Future.wait([
      adminService.getUsers(page: 1, pageSize: 1),
      adminService.getUsers(page: 1, pageSize: 1, isActive: true),
    ]);
    _userTotalCount = results[0].totalCount;
    _userActiveCount = results[1].totalCount;
    notifyListeners();
  }

  Future<void> loadUsers({bool resetPage = false}) async {
    if (resetPage) _usersPage = 1;
    _usersLoading = true;
    _usersError = null;
    notifyListeners();

    try {
      final result = await adminService.getUsers(
        search: _userQuery,
        role: _userRoleFilter,
        isActive: _userStatusFilter,
        page: _usersPage,
        pageSize: _usersPageSize,
      );
      _users = result.items;
      _usersTotalCount = result.totalCount;
      _usersTotalPages = result.totalPages < 1 ? 1 : result.totalPages;
    } catch (e) {
      _usersError = ApiResponseHandler.describe(e);
    } finally {
      _usersLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUsersPage(int page) async {
    if (page < 1 || page > _usersTotalPages || page == _usersPage) return;
    _usersPage = page;
    await loadUsers();
  }

  Future<void> setUsersPageSize(int pageSize) async {
    if (pageSize == _usersPageSize) return;
    _usersPageSize = pageSize;
    await loadUsers(resetPage: true);
  }

  Future<String> updateUser({
    required String userId,
    required Map<String, dynamic> changes,
  }) async {
    final message =
        await adminService.updateUser(userId: userId, changes: changes);
    await Future.wait([loadUsers(), loadUserCounts()]);
    return message;
  }

  Future<String> resetUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    final message = await adminService.resetPassword(
      userId: userId,
      newPassword: newPassword,
    );
    await loadUsers();
    return message;
  }

  /// Vlastita lozinka ide kroz `User/UpdatePassword`, koji traži staru
  /// i vraća novi token — sesija se zato ne prekida.
  Future<String> changeOwnPassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      adminService.changeOwnPassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

  Future<String> addAdministrator(Map<String, dynamic> body) async {
    final message = await adminService.addAdministrator(body);
    await Future.wait([loadUsers(resetPage: true), loadUserCounts()]);
    return message;
  }

  Future<void> getReservations() async {
    _reservations = await adminService.getReservations(
      start: _reservationStart,
      end: _reservationEnd,
    );
    notifyListeners();
  }

  Future<void> loadReservations({bool resetPage = false}) async {
    if (resetPage) _reservationsPage = 1;
    _reservationsLoading = true;
    _reservationsError = null;
    notifyListeners();

    final now = DateTime.now().toUtc();
    final start = _reservationStart ?? now.subtract(const Duration(days: 365));
    final end = _reservationEnd ?? now.add(const Duration(days: 365));

    try {
      final result = await adminService.getReservationsPage(
        start: start,
        end: end,
        search: _reservationQuery,
        status: _reservationStatusFilter,
        page: _reservationsPage,
        pageSize: _reservationsPageSize,
      );
      _reservationsList = result.items;
      _reservationsTotalCount = result.totalCount;
      _reservationsTotalPages = result.totalPages < 1 ? 1 : result.totalPages;
    } catch (e) {
      _reservationsError = ApiResponseHandler.describe(e);
    } finally {
      _reservationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> setReservationsPage(int page) async {
    if (page < 1 || page > _reservationsTotalPages || page == _reservationsPage) return;
    _reservationsPage = page;
    await loadReservations();
  }

  Future<void> setReservationsPageSize(int pageSize) async {
    if (pageSize == _reservationsPageSize) return;
    _reservationsPageSize = pageSize;
    await loadReservations(resetPage: true);
  }

  Future<String> changeReservationStatus({
    required String reservationId,
    required ReservationStatus status,
    String? reason,
  }) async {
    final message = await adminService.changeReservationStatus(
      reservationId: reservationId,
      status: status,
      reason: reason,
    );
    await loadReservations();
    return message;
  }

  Future<List<ReservationStatusHistoryGET>> historyFor(String reservationId) =>
      adminService.getReservationHistory(reservationId);

  Future<({PaymentGET payment, String message})> paymentFor(String reservationId) =>
      adminService.getPayment(reservationId);

  // ── Akcije ──────────────────────────────────────────────────────────────

  /// Deaktivira korisnički nalog. Vraća poruku sa servera.
  Future<String> deleteUser(String userId) async {
    final message = await adminService.deleteUser(userId);
    // Optimistično uklanjanje bi sakrilo neuspjeh, pa radije osvježimo stranicu.
    await Future.wait([loadUsers(), loadUserCounts()]);
    return message;
  }

  /// Aktivira/deaktivira smještaj i osvježava trenutnu stranicu, plus puni
  /// skup koji koriste dashboard i izvještaji.
  Future<String> setAccommodationStatus({
    required String accommodationId,
    required bool status,
  }) async {
    final message = await adminService.setAccommodationStatus(
      accommodationId: accommodationId,
      status: status,
    );
    await Future.wait([loadProperties(), getAccommodations()]);
    return message;
  }

  /// Briše smještaj i osvježava trenutnu stranicu, plus puni skup koji koriste
  /// dashboard i izvještaji.
  Future<String> deleteAccommodation(String accommodationId) async {
    final message = await adminService.deleteAccommodation(accommodationId);
    await Future.wait([loadProperties(), getAccommodations()]);
    return message;
  }

  Future<List<AccommodationReview>> reviewsFor(String accommodationId) =>
      adminService.getReviews(accommodationId);

  // ── Filteri ─────────────────────────────────────────────────────────────

  Future<void> setPropertyQuery(String value) async {
    if (value == _propertyQuery) return;
    _propertyQuery = value;
    await loadProperties(resetPage: true);
  }

  Future<void> setPropertyCityFilter(String? cityId) async {
    _propertyCityFilter = cityId;
    await loadProperties(resetPage: true);
  }

  Future<void> setPropertyTypeFilter(String? accommodationTypeId) async {
    _propertyTypeFilter = accommodationTypeId;
    await loadProperties(resetPage: true);
  }

  Future<void> setPropertyStatusFilter(bool? status) async {
    _propertyStatusFilter = status;
    await loadProperties(resetPage: true);
  }

  Future<void> setReservationQuery(String value) async {
    if (value == _reservationQuery) return;
    _reservationQuery = value;
    await loadReservations(resetPage: true);
  }

  Future<void> setReservationStatusFilter(ReservationStatus? status) async {
    _reservationStatusFilter = status;
    await loadReservations(resetPage: true);
  }

  Future<void> setReservationRange(DateTime? start, DateTime? end) async {
    _reservationStart = start;
    _reservationEnd = end;
    notifyListeners();
    await Future.wait([getReservations(), loadReservations(resetPage: true)]);
  }

  Future<void> setUserQuery(String value) async {
    if (value == _userQuery) return;
    _userQuery = value;
    await loadUsers(resetPage: true);
  }

  Future<void> setUserStatusFilter(bool? status) async {
    _userStatusFilter = status;
    await loadUsers(resetPage: true);
  }

  Future<void> setUserRoleFilter(UserRole? role) async {
    _userRoleFilter = role;
    await loadUsers(resetPage: true);
  }

  // ── Izvedeni podaci ─────────────────────────────────────────────────────

  /// Gradovi koji se stvarno pojavljuju u smještajima — za dropdown filter.
  List<String> get availableCities {
    final cities = _accommodations
        .map((a) => a.location.cityName)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return cities;
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
