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
      throw const ApiException(500, 'Unexpected profile format from the server.');
    }
    return Profile.fromJson(data);
  }

  /// `PATCH /api/Administrator/Update` — puni skup polja, jer izostavljeno
  /// polje server prepisuje praznom vrijednošću.
  Future<({Profile profile, String message})> updatePersonalDetails(
    Profile profile,
  ) async {
    final response = await http.patch(
      Uri.parse('${config.AppConfig.baseUrl}/api/Administrator/Update'),
      headers: await _headers(withBody: true),
      body: jsonEncode(profile.toJson()),
    );
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException(500, 'Unexpected profile format from the server.');
    }
    return (
      profile: Profile.fromJson(data),
      message: ApiResponseHandler.successMessage(
          response, 'Administrator details successfully updated.'),
    );
  }

  /// `PATCH /api/User/UpdateEmail`
  Future<String> updateEmail(String newEmail, String password) async {
    final response = await http.patch(
      Uri.parse('${config.AppConfig.baseUrl}/api/User/UpdateEmail'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'email': newEmail, 'password': password}),
    );
    await _saveRefreshedToken(response);

    return ApiResponseHandler.successMessage(
        response, 'Email address successfully updated.');
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
    await _saveRefreshedToken(response);

    return ApiResponseHandler.successMessage(
        response, 'Password successfully updated.');
  }

  Future<void> _saveRefreshedToken(http.Response response) async {
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) return;

    final token = data['token'];
    if (token is String && token.trim().isNotEmpty) {
      await _secureStorage.saveToken(token.trim());
    }
  }
}
