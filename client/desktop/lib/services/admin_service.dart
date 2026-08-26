import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/models/reservation_model.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/auth_service.dart';

/// HTTP sloj za administratorske preglede.
///
/// Izmjene u odnosu na raniju verziju:
///  - `.then((response) { ... })` lanci zamijenjeni sa `await` (čitljivije i
///    konzistentno sa ostatkom projekta; Upute 8.2 traže async/await kroz stack).
///  - Generičke poruke `throw Exception('Failed to load X')` zamijenjene
///    `ApiException`-om koji nosi stvarnu serversku poruku.
///  - `getProfiles` više ne radi `Future.wait` — `Profile.fromJson` je sad
///    sinhron jer ne piše slike na disk.
///  - Datumski raspon za rezervacije više nije hardkodiran na 30 dana.
class AdminService {
  final SecureStorage _secureStorage;

  AdminService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  String get _base => '${config.AppConfig.baseUrl}/api/Administrator';

  Future<Map<String, String>> _headers() async {
    final token = await _secureStorage.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AccommodationGET>> getAccommodations() async {
    final response = await http.get(
      Uri.parse('$_base/Accommodations'),
      headers: await _headers(),
    );
    return ApiResponseHandler.unwrapList(response)
        .map(AccommodationGET.fromJson)
        .toList();
  }

  Future<List<Profile>> getProfiles() async {
    final response = await http.get(
      Uri.parse('$_base/Customers'),
      headers: await _headers(),
    );
    return ApiResponseHandler.unwrapList(response)
        .map(Profile.fromJson)
        .toList();
  }

  /// `GET /api/Administrator/Reservations?start=&end=`
  ///
  /// Backend zahtijeva oba parametra. Default je posljednjih 12 mjeseci jer
  /// izvještaji ("Rezervacije po gradovima") trebaju širi prozor od
  /// dashboard trenda; dashboard sam filtrira na zadnjih 30 dana lokalno.
  Future<List<ReservationGET>> getReservations({
    DateTime? start,
    DateTime? end,
  }) async {
    final now = DateTime.now().toUtc();
    final from = start ?? now.subtract(const Duration(days: 365));
    final to = end ?? now.add(const Duration(days: 365));

    final uri = Uri.parse('$_base/Reservations').replace(queryParameters: {
      'start': from.toIso8601String(),
      'end': to.toIso8601String(),
    });

    final response = await http.get(uri, headers: await _headers());
    return ApiResponseHandler.unwrapList(response)
        .map(ReservationGET.fromJson)
        .toList();
  }

  /// `DELETE /api/Administrator/DeleteUser?userId=`
  ///
  /// Backend radi soft delete preko `IGenericRepository.Delete`.
  Future<String> deleteUser(String userId) async {
    final uri = Uri.parse('$_base/DeleteUser')
        .replace(queryParameters: {'userId': userId});
    final response = await http.delete(uri, headers: await _headers());
    return ApiResponseHandler.successMessage(
        response, 'Korisnički nalog je uspješno deaktiviran.');
  }
}
