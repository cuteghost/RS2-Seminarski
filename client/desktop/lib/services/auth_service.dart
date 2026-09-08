import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/services/api_response_handler.dart';

/// Rezultat prijave — uspjeh + poruka, da UI može prikazati konkretan razlog
/// neuspjeha umjesto da tiho ne uradi ništa.
typedef LoginResult = ({bool success, String message});

typedef LogoutResult = ({bool serverNotified, String message});

class AuthService {
  final SecureStorage _secureStorage;

  AuthService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  /// `POST /api/Auth/login`
  ///
  /// Vraća razlog neuspjeha (pogrešna lozinka / nema mreže / server pao),
  /// ne goli `bool`, da UI ima šta prikazati korisniku.
  Future<LoginResult> login(String email, String password) async {
    await _secureStorage.deleteToken();
    try {
      final response = await http.post(
        Uri.parse('${config.AppConfig.baseUrl}/api/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final token = _readToken(response);
        if (token == null) {
          return (
            success: false,
            message: 'The server did not return a login token. '
                'Please check the API service version.',
          );
        }

        await _secureStorage.saveToken(token);
        return (
          success: true,
          message: ApiResponseHandler.successMessage(response, 'Login successful.'),
        );
      }

      if (response.statusCode == 401 || response.statusCode == 400) {
        return (
          success: false,
          message: 'Incorrect email address or password.',
        );
      }

      return (
        success: false,
        message: ApiResponseHandler.extractMessage(response),
      );
    } catch (e) {
      return (success: false, message: ApiResponseHandler.describe(e));
    }
  }

  Future<LogoutResult> logout() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      await _secureStorage.deleteToken();
      return (serverNotified: true, message: 'Logout successful.');
    }

    try {
      final response = await http.post(
        Uri.parse('${config.AppConfig.baseUrl}/api/Auth/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );

      await _secureStorage.deleteToken();

      if (response.statusCode == 200) {
        return (
          serverNotified: true,
          message: ApiResponseHandler.successMessage(
              response, 'Logout successful.'),
        );
      }

      if (response.statusCode == 401) {
        return (serverNotified: true, message: 'Logout successful.');
      }

      return (
        serverNotified: false,
        message: 'You have been logged out locally, but the server did not confirm '
            'the token was revoked: ${ApiResponseHandler.extractMessage(response)}',
      );
    } catch (e) {
      await _secureStorage.deleteToken();
      return (
        serverNotified: false,
        message: 'You have been logged out locally, but the server is unreachable so the '
            'token was not revoked. ${ApiResponseHandler.describe(e)}',
      );
    }
  }

  /// `GET /api/Auth/status` — provjerava da li je sačuvani token još validan
  /// i osvježava ga.
  Future<bool> checkLoggedIn() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('${config.AppConfig.baseUrl}/api/Auth/status'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final token = _readToken(response);
        if (token == null) {
          await _secureStorage.deleteToken();
          return false;
        }

        await _secureStorage.saveToken(token);
        return true;
      }
      await _secureStorage.deleteToken();
      return false;
    } catch (_) {
      // Server nedostupan pri startu — ne brišemo token da korisnik ne bi
      // bio odjavljen samo zato što API još nije podignut.
      return false;
    }
  }

  String? _readToken(http.Response response) {
    try {
      final data = ApiResponseHandler.unwrap(response);
      if (data is! Map<String, dynamic>) return null;

      final token = data['token'];
      if (token is! String || token.trim().isEmpty) return null;

      return token.trim();
    } on ApiException {
      return null;
    }
  }

  /// Čita rolu iz JWT payload-a.
  ///
  /// NAPOMENA: ovo je samo dekodiranje payload-a radi rutiranja UI-ja —
  /// NIJE sigurnosna provjera. Autorizacija se validira na serveru
  /// (`[Authorize(Roles = Roles.Administrator)]`), gdje se i verifikuje potpis.
  Future<String> roleCheck() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) return '';

    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = json.decode(payload);
      if (claims is! Map<String, dynamic>) return '';

      const roleClaim =
          'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
      final role = claims[roleClaim] ?? claims['role'];

      if (role is String) return role;
      if (role is List && role.isNotEmpty) return role.first.toString();
      return '';
    } catch (_) {
      return '';
    }
  }
}

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  static const _key = 'jwt_token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  Future<String?> getToken() => _storage.read(key: _key);

  Future<void> deleteToken() => _storage.delete(key: _key);
}
