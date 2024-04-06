import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart' as config;


class AuthService {
  final SecureStorage _secureStorage = SecureStorage();

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${config.AppConfig.baseUrl}/api/Login/customer');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}));

    if (response.statusCode == 200) {
      await _secureStorage.saveToken(response.body); // Assuming the token is the entire response body
      return true;
    } else {
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    // Placeholder for actual Facebook login implementation
    // For demonstration, we'll assume the login is successful and a token is received
    String fakeFacebookToken = "fake_facebook_token";
    await _secureStorage.saveToken(fakeFacebookToken);
    return true;
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }

  Future<bool> checkLoggedIn() async {
    String? token = await _secureStorage.getToken();
    http.Response response = await http.get(
      Uri.parse('${config.AppConfig.baseUrl}/api/Auth/status'),
      headers: {'Authorization': 'Bearer $token'}
    );
    if (response.statusCode == 200) {
      await _secureStorage.saveToken(response.body);
      return true;
    }
    else {
      await _secureStorage.deleteToken();
      return false;
    }
  }
}
class SecureStorage
{
  final _storage = FlutterSecureStorage(); 

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }
}