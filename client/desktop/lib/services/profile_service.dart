import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/auth_service.dart';

class ProfileService {
  final SecureStorage _secureStorage;

  ProfileService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Future<Map<String, String>> _headers({bool withBody = false}) async {
    final token = await _secureStorage.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (withBody) 'Content-Type': 'application/json',
    };
  }

  /// `GET /api/Administrator/Details`
  Future<Profile> fetchProfile() async {
    final response = await http.get(
      Uri.parse('${config.AppConfig.baseUrl}/api/Administrator/Details'),
      headers: await _headers(),
    );
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException(500, 'Neočekivan oblik profila sa servera.');
    }
    return Profile.fromJson(data);
  }

  /// `PATCH /api/User/UpdateEmail`
  Future<String> updateEmail(String newEmail, String password) async {
    final response = await http.patch(
      Uri.parse('${config.AppConfig.baseUrl}/api/User/UpdateEmail'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'email': newEmail, 'password': password}),
    );
    // 401 ovdje znači "pogrešna lozinka", ne "istekla sesija" — backend
    // koristi isti status za oboje. Prijavljeno kao backend nedostatak.
    if (response.statusCode == 401) {
      throw const ApiException(401, 'Unesena lozinka nije ispravna.');
    }
    return ApiResponseHandler.successMessage(
        response, 'E-mail adresa je uspješno izmijenjena.');
  }

  /// `PATCH /api/User/UpdatePassword`
  Future<String> updatePassword(String oldPassword, String newPassword) async {
    final response = await http.patch(
      Uri.parse('${config.AppConfig.baseUrl}/api/User/UpdatePassword'),
      headers: await _headers(withBody: true),
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode == 401) {
      throw const ApiException(401, 'Trenutna lozinka nije ispravna.');
    }
    return ApiResponseHandler.successMessage(
        response, 'Lozinka je uspješno izmijenjena.');
  }
}
