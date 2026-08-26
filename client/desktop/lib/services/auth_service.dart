import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/services/api_response_handler.dart';

/// Rezultat prijave — uspjeh + poruka, da UI može prikazati konkretan razlog
/// neuspjeha umjesto da tiho ne uradi ništa.
typedef LoginResult = ({bool success, String message});

class AuthService {
  final SecureStorage _secureStorage;

  AuthService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  /// `POST /api/Auth/login`
  ///
  /// Upute 5: "Login kredencijali šalju se u body-ju POST zahtjeva, nikada
  /// kroz query string parametre." — ispunjeno.
  ///
  /// BUGFIX: ranije je vraćao goli `bool`, pa je `login.dart` na `false`
  /// radio samo `return;` i korisnik nije dobijao NIKAKVU poruku. Sada se
  /// razlog (pogrešna lozinka / nema mreže / server pao) propagira u UI.
  Future<LoginResult> login(String email, String password) async {
    await _secureStorage.deleteToken();
    try {
      final response = await http.post(
        Uri.parse('${config.AppConfig.baseUrl}/api/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        await _secureStorage.saveToken(response.body);
        return (success: true, message: 'Prijava uspješna.');
      }

      if (response.statusCode == 401 || response.statusCode == 400) {
        return (
          success: false,
          message: 'Pogrešna e-mail adresa ili lozinka.',
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

  Future<void> logout() async {
    // NAPOMENA (Upute 5): "Logout mora invalidirati token na serveru, a ne
    // samo lokalno obrisati token." Backend trenutno nema logout endpoint
    // niti token blacklist — prijavljeno kao nedostajuća backend funkcionalnost.
    await _secureStorage.deleteToken();
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
        await _secureStorage.saveToken(response.body);
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
