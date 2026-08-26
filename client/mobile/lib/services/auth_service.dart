import 'dart:io';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart' as config;

class AuthService {
  final SecureStorage _secureStorage;

  /// google_sign_in 7.x requires [GoogleSignIn.initialize] to be called exactly
  /// once per process before any other method on the singleton.
  static Future<void>? _googleSignInInit;

  static const List<String> _googleScopes = <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  AuthService({required this._secureStorage});

  Future<bool> login(String email, String password) async {
    await _secureStorage.deleteToken();
    final url = Uri.parse('${config.AppConfig.baseUrl}/api/Auth/login');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}));

    if (response.statusCode == 200) {
      await _secureStorage.saveToken(response.body);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    await _secureStorage.deleteToken();
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      final response = await http.post(
        Uri.parse('${config.AppConfig.baseUrl}/api/Auth/facebook-login'),
        body: json.encode({'accessToken': accessToken.tokenString}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await _secureStorage.saveToken(response.body);
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }

  Future<bool> checkLoggedIn() async {
    String? token = await _secureStorage.getToken();
    http.Response response = await http.get(
        Uri.parse('${config.AppConfig.baseUrl}/api/Auth/status'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      await _secureStorage.saveToken(response.body);
      return true;
    } else {
      await _secureStorage.deleteToken();
      return false;
    }
  }
  //Fill with the requireq parameters

  Future<bool> register(String email, String password, String displayName,
      String firstName, String lastName, String birthDate, File image) async {
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
          'password': password
        }));
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
    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      await _secureStorage.deleteToken();
    } else {
      throw Exception('Failed to delete account');
    }
  }

  /// Runs [GoogleSignIn.initialize] once per process, as 7.x requires. On
  /// failure the cached future is cleared so a later attempt can retry.
  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInit ??= GoogleSignIn.instance
        .initialize(serverClientId: config.AppConfig.googleServerClientId)
        .catchError((Object error) {
      _googleSignInInit = null;
      throw error;
    });
  }

  Future<bool> loginWithGoogle() async {
    await _secureStorage.deleteToken();

    final GoogleSignInAccount googleUser;
    final GoogleSignInClientAuthorization authorization;
    try {
      await _ensureGoogleSignInInitialized();

      // Throws GoogleSignInException instead of returning null when the user
      // cancels, so the old `googleUser == null` check becomes this catch.
      googleUser = await GoogleSignIn.instance
          .authenticate(scopeHint: _googleScopes);

      // 7.x moved the access token off GoogleSignInAuthentication; it now comes
      // from the authorization client, which the server contract still needs.
      authorization = await googleUser.authorizationClient
              .authorizationForScopes(_googleScopes) ??
          await googleUser.authorizationClient.authorizeScopes(_googleScopes);
    } on GoogleSignInException {
      return false;
    }

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final response = await http.post(
      Uri.parse('${config.AppConfig.baseUrl}/api/Auth/google-login'),
      body: json.encode({
        'IdToken': googleAuth.idToken,
        'AccessToken': authorization.accessToken
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await _secureStorage.saveToken(
          response.body); // Assuming the token is the entire response body
      return true;
    } else {
      return false;
    }
  }

  Future<bool> registerPartner(Map<String, dynamic> partner) async {
    String? token = await _secureStorage.getToken();
    final response = await http.post(
        Uri.parse('${config.AppConfig.baseUrl}/api/Partner/Add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(partner));
    if (response.statusCode == 200) {
      await _secureStorage.deleteToken();
      await _secureStorage.saveToken(response.body);
      return false;
    } else {
      throw Exception('Failed to register partner');
    }
  }

  Future<String> roleCheck() async {
    // Implement role check
    String? authToken = await _secureStorage.getToken();
    if (authToken != null) {
      // Check the role of the user
      // authToken is the JWT token. It holds the claim Role. Decode the token and check the role
      var payload = authToken.split('.')[1];
      var normalizedPayload = base64Url.normalize(payload);
      var stringPayload = utf8.decode(base64Url.decode(normalizedPayload));
      var payloadMap = json.decode(stringPayload);
      if (payloadMap[
              'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ==
          'Partner') {
        return 'Partner';
      } else {
        return 'Customer';
      }
    }
    return '';
  }
}

class SecureStorage {
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
