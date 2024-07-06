import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebooking_desktop/config/config.dart' as config;


class AuthService {
  final SecureStorage _secureStorage;
  
  AuthService({required SecureStorage secureStorage}) : _secureStorage = secureStorage;

  Future<bool> login(String email, String password) async {
    await _secureStorage.deleteToken();
    final url = Uri.parse('${config.AppConfig.baseUrl}/api/Auth/login');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}));
    print(response.body);
    if (response.statusCode == 200) {
      await _secureStorage.saveToken(response.body);
      return true;
    } else {
      return false;
    }
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

  Future<bool> register(String email, String password, String displayName, String firstName, String lastName, String birthDate, File image) async {
    final url = Uri.parse('${config.AppConfig.baseUrl}/api/Customer/register');
    List<int> imageBytes = image.readAsBytesSync();
    String base64image = base64Encode(imageBytes);
    
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'displayName': displayName, 
          'firstName': firstName, 
          'lastName': lastName,  
          'birthDate': birthDate, 
          'image': base64image, 
          'email': email, 
          'password': password}));
    if (response.statusCode == 200) {
      await _secureStorage.saveToken(response.body);
      return true;
    } else {
      return false;
    }
  }

  void deleteAccount() async {
    final url = Uri.parse('${config.AppConfig.baseUrl}/api/Customer/Delete');
    String? token = await _secureStorage.getToken();
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      await _secureStorage.deleteToken();
    }
    else {
      throw Exception('Failed to delete account');
    }
  }

  roleCheck() async{
    // Implement role check
    String? authToken = await _secureStorage.getToken();
    if (authToken != null) {
      // Check the role of the user
      // authToken is the JWT token. It holds the claim Role. Decode the token and check the role
      var payload = authToken.split('.')[1];
      print('Payload: $payload');
      var normalizedPayload = base64Url.normalize(payload);
      var stringPayload = utf8.decode(base64Url.decode(normalizedPayload));
      var payloadMap = json.decode(stringPayload);
      if (payloadMap['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] == 'Administrator') {
        return 'Administrator';
      }
    }
    return '';
  
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