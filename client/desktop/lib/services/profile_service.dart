import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/services/auth_service.dart';
import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileService {
  final SecureStorage _secureStorage;

  ProfileService({required SecureStorage secureStorage}) : _secureStorage = secureStorage;

  Future<Profile> fetchProfile() async {
    String? token = await _secureStorage.getToken();
    final response = await http.get(
      Uri.parse('${config.AppConfig.baseUrl}/api/Administrator/Details'),
      headers: {'Authorization': 'Bearer $token'}
    );
    if (response.statusCode == 200) {
      return Profile.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 401) {
        throw Exception('401 Unauthorized');
    }
    else {
      throw Exception('Failed to load profile');
    }
  }

  Future<bool> updateProfile(Profile profile) async {
    String? token = await _secureStorage.getToken();
    final response = await http.patch(
      Uri.parse('${config.AppConfig.baseUrl}/api/Customer/UpdateDetails'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(profile.toJson())
    );
    if (response.statusCode == 200) {
      return true;
    }
    if (response.statusCode == 401) {
        throw Exception('401 Unauthorized');
    }
    else {
      throw Exception('Failed to update profile');
    }
  }

  Future<bool> updateEmail(String newEmail, String password) async {
    String? token = await _secureStorage.getToken();
    final response = await http.patch(
      Uri.parse('${config.AppConfig.baseUrl}/api/User/UpdateEmail'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'email': newEmail,
        'password': password
      })
    );
    if (response.statusCode == 200) {
      return true;
    }
    if (response.statusCode == 401) {
        throw Exception('Wrong Password');
    }
    else {
      throw Exception('Failed to update email');
    }
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    String? token = await _secureStorage.getToken();
    final response = await http.patch(
      Uri.parse('${config.AppConfig.baseUrl}/api/User/UpdatePassword'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword
      })
    );
    if (response.statusCode == 200) {
      return true;
    }
    if (response.statusCode == 401) {
        throw Exception('Wrong Password');
    }
    else {
      throw Exception('Failed to update password');
    }
  }
}
