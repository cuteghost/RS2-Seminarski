import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/models/accommodation_review.dart';
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/models/reservation_model.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/auth_service.dart';
import 'package:ebooking_desktop/services/paged.dart';

/// HTTP sloj za administratorske preglede.
class AdminService {
  final SecureStorage _secureStorage;

  AdminService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  String get _base => '${config.AppConfig.baseUrl}/api/Administrator';

  Future<Map<String, String>> _headers({bool withBody = false}) async {
    final token = await _secureStorage.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (withBody) 'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<String?> currentToken() => _secureStorage.getToken();

  Future<List<AccommodationGET>> getAccommodations() {
    return Paged.all<AccommodationGET>((page, pageSize) async {
      final response = await http.get(
        Uri.parse('$_base/Accommodations?page=$page&pageSize=$pageSize'),
        headers: await _headers(),
      );
      return Paged.read(response, AccommodationGET.fromJson);
    });
  }

  Future<PagedResult<AccommodationGET>> getAccommodationsPage({
    String? search,
    String? cityId,
    String? accommodationTypeId,
    bool? status,
    int page = 1,
    int pageSize = Paged.maxPageSize,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (cityId != null && cityId.isNotEmpty) 'cityId': cityId,
      if (accommodationTypeId != null && accommodationTypeId.isNotEmpty)
        'accommodationTypeId': accommodationTypeId,
      if (status != null) 'status': '$status',
    };
    final uri = Uri.parse('$_base/Accommodations').replace(queryParameters: query);
    final response = await http.get(uri, headers: await _headers());
    return Paged.read(response, AccommodationGET.fromJson);
  }

  Future<PagedResult<Profile>> getUsers({
    String? search,
    UserRole? role,
    bool? isActive,
    int page = 1,
    int pageSize = Paged.maxPageSize,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (role != null) 'role': '${role.index}',
      if (isActive != null) 'isActive': '$isActive',
    };
    final uri = Uri.parse('$_base/Users').replace(queryParameters: query);
    final response = await http.get(uri, headers: await _headers());
    return Paged.read(response, Profile.fromJson);
  }

  /// `GET /api/Administrator/Details` — prijavljeni administrator.
  ///
  /// Backend nema rutu koja vraća **sve** administratore, pa je ovo jedini
  /// administratorski nalog koji pregled može prikazati.
  Future<Profile?> getSignedInAdministrator() async {
    final response = await http.get(
      Uri.parse('$_base/Details'),
      headers: await _headers(),
    );
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) return null;
    return Profile.fromJson(data, role: UserRole.administrator);
  }

  /// `PATCH /api/Administrator/UpdateUser/{userId}` — izmjena tuđeg naloga.
  Future<String> updateUser({
    required String userId,
    required Map<String, dynamic> changes,
  }) async {
    final response = await http.patch(
      Uri.parse('$_base/UpdateUser/$userId'),
      headers: await _headers(withBody: true),
      body: jsonEncode(changes),
    );
    return ApiResponseHandler.successMessage(
        response, 'User details successfully updated.');
  }

  /// `PATCH /api/Administrator/ResetPassword/{userId}` — tuđa lozinka, bez stare.
  Future<String> resetPassword({
    required String userId,
    required String newPassword,
  }) async {
    final response = await http.patch(
      Uri.parse('$_base/ResetPassword/$userId'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'newPassword': newPassword}),
    );
    return ApiResponseHandler.successMessage(
        response, 'User password successfully set.');
  }

  /// `PATCH /api/User/UpdatePassword` — vlastita lozinka, uz potvrdu stare.
  ///
  /// Vraća novi token jer promjena lozinke podiže `TokenVersion`; bez spremanja
  /// bi sljedeći zahtjev pao na 401.
  Future<String> changeOwnPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await http.patch(
      Uri.parse('${config.AppConfig.baseUrl}/api/User/UpdatePassword'),
      headers: await _headers(withBody: true),
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    final data = ApiResponseHandler.unwrap(response);
    if (data is Map<String, dynamic>) {
      final token = data['token'];
      if (token is String && token.trim().isNotEmpty) {
        await _secureStorage.saveToken(token.trim());
      }
    }

    return ApiResponseHandler.successMessage(
        response, 'Password successfully updated.');
  }

  /// `POST /api/Administrator/Add`
  Future<String> addAdministrator(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_base/Add'),
      headers: await _headers(withBody: true),
      body: jsonEncode(body),
    );
    return ApiResponseHandler.successMessage(
        response, 'Administrator successfully created.');
  }

  /// `GET /api/Administrator/Reservations?start=&end=`
  ///
  /// Backend zahtijeva oba parametra. Default je posljednjih 12 mjeseci jer
  /// izvještaji ("Rezervacije po gradovima") trebaju širi prozor od
  /// dashboard trenda; dashboard sam filtrira na zadnjih 30 dana lokalno.
  Future<List<ReservationGET>> getReservations({
    DateTime? start,
    DateTime? end,
  }) {
    final now = DateTime.now().toUtc();
    final from = start ?? now.subtract(const Duration(days: 365));
    final to = end ?? now.add(const Duration(days: 365));

    return Paged.all<ReservationGET>((page, pageSize) async {
      final uri = Uri.parse('$_base/Reservations').replace(queryParameters: {
        'start': from.toIso8601String(),
        'end': to.toIso8601String(),
        'page': '$page',
        'pageSize': '$pageSize',
      });

      final response = await http.get(uri, headers: await _headers());
      return Paged.read(response, ReservationGET.fromJson);
    });
  }

  Future<PagedResult<ReservationGET>> getReservationsPage({
    required DateTime start,
    required DateTime end,
    String? search,
    ReservationStatus? status,
    int page = 1,
    int pageSize = Paged.maxPageSize,
  }) async {
    final query = <String, String>{
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null) 'status': '${status.value}',
    };
    final uri = Uri.parse('$_base/Reservations').replace(queryParameters: query);
    final response = await http.get(uri, headers: await _headers());
    return Paged.read(response, ReservationGET.fromJson);
  }

  /// `PATCH /api/Reservation/Status`
  Future<String> changeReservationStatus({
    required String reservationId,
    required ReservationStatus status,
    String? reason,
  }) async {
    final response = await http.patch(
      Uri.parse('${config.AppConfig.baseUrl}/api/Reservation/Status'),
      headers: await _headers(withBody: true),
      body: jsonEncode({
        'reservationId': reservationId,
        'status': status.value,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      }),
    );
    return ApiResponseHandler.successMessage(
        response, 'Reservation status successfully changed.');
  }

  /// `GET /api/Reservation/History/{id}`
  Future<List<ReservationStatusHistoryGET>> getReservationHistory(String id) async {
    final response = await http.get(
      Uri.parse('${config.AppConfig.baseUrl}/api/Reservation/History/$id'),
      headers: await _headers(),
    );
    return ApiResponseHandler.unwrapList(response)
        .map(ReservationStatusHistoryGET.fromJson)
        .toList();
  }

  /// `GET /api/Payment/ByReservation/{id}`
  ///
  /// Kad plaćanje nije započeto server svejedno vraća 200 sa očekivanim iznosom
  /// i porukom koja to kaže, pa se vraćaju oba.
  Future<({PaymentGET payment, String message})> getPayment(String id) async {
    final response = await http.get(
      Uri.parse('${config.AppConfig.baseUrl}/api/Payment/ByReservation/$id'),
      headers: await _headers(),
    );

    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException(500, 'Unexpected payment response format.');
    }

    return (
      payment: PaymentGET.fromJson(data),
      message: ApiResponseHandler.successMessage(response, ''),
    );
  }

  /// `PATCH /api/Accommodation/Status/{id}?status=`
  Future<String> setAccommodationStatus({
    required String accommodationId,
    required bool status,
  }) async {
    final uri = Uri.parse('${config.AppConfig.baseUrl}/api/Accommodation/Status/$accommodationId')
        .replace(queryParameters: {'status': '$status'});
    final response = await http.patch(uri, headers: await _headers());
    return ApiResponseHandler.successMessage(
        response, 'Property status successfully changed.');
  }

  /// `DELETE /api/Accommodation/Delete/{id}`
  Future<String> deleteAccommodation(String accommodationId) async {
    final response = await http.delete(
      Uri.parse('${config.AppConfig.baseUrl}/api/Accommodation/Delete/$accommodationId'),
      headers: await _headers(),
    );
    return ApiResponseHandler.successMessage(
        response, 'Property successfully deleted.');
  }

  /// `GET /api/Feedback/ByAccommodation/{id}?onlyWithComment=&page=&pageSize=`
  Future<List<AccommodationReview>> getReviews(String accommodationId) {
    return Paged.all<AccommodationReview>((page, pageSize) async {
      final response = await http.get(
        Uri.parse('${config.AppConfig.baseUrl}/api/Feedback/ByAccommodation/'
            '$accommodationId?onlyWithComment=false&page=$page&pageSize=$pageSize'),
        headers: await _headers(),
      );
      return Paged.read(response, AccommodationReview.fromJson);
    });
  }

  /// `DELETE /api/Administrator/DeleteUser?userId=`
  ///
  /// Backend radi soft delete preko `IGenericRepository.Delete`.
  Future<String> deleteUser(String userId) async {
    final uri = Uri.parse('$_base/DeleteUser')
        .replace(queryParameters: {'userId': userId});
    final response = await http.delete(uri, headers: await _headers());
    return ApiResponseHandler.successMessage(
        response, 'User account successfully deactivated.');
  }
}
