import 'dart:convert';
import 'dart:io';

import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/config/config.dart' as config;
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/secure_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Reads the token out of `{ message, data: { token } }`, which is what login,
/// the refresh, the status check, Google sign-in and partner registration all
/// answer with now that the API no longer returns a bare token in the body.
String _tokenFrom(dynamic data) =>
    (data as Map<String, dynamic>)['token'] as String;

class AuthService {
  AuthService({required this._apiClient, required this._secureStorage});

  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  /// google_sign_in 7.x requires [GoogleSignIn.initialize] to be called exactly
  /// once per process before any other method on the singleton.
  static Future<void>? _googleSignInInit;

  static const List<String> _googleScopes = <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  /// Throws [ApiException] carrying the server's own message when the sign-in
  /// is refused — a wrong password answers `401` *with* a body, which is why
  /// this call does not treat a `401` as an expired session.
  Future<void> login(String email, String password) async {
    await _secureStorage.deleteToken();
    final token = await _apiClient.post<String>(
      '/api/Auth/login',
      body: <String, String>{'email': email, 'password': password},
      authenticated: false,
      unauthorizedIsExpiredSession: false,
      parse: _tokenFrom,
    );
    await _secureStorage.saveToken(token);
  }

  Future<void> loginWithFacebook() async {
    if (!config.AppConfig.isFacebookSignInConfigured) {
      throw ApiException(
        0,
        'Facebook sign-in is unavailable: this build was made without '
        'FACEBOOK_APP_ID.',
      );
    }
    await _secureStorage.deleteToken();

    final LoginResult result;
    try {
      result = await FacebookAuth.instance.login();
    } catch (error) {
      throw ApiException(
        0,
        'Facebook sign-in could not start on this device: $error',
      );
    }
    if (result.status != LoginStatus.success) {
      throw ApiException(0, 'Facebook sign-in was cancelled.');
    }

    final accessToken = result.accessToken?.tokenString;
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        0,
        'Facebook did not return an access token. Try signing in again.',
      );
    }

    final token = await _apiClient.post<String>(
      '/api/Auth/facebook-login',
      body: <String, String>{'accessToken': accessToken},
      authenticated: false,
      unauthorizedIsExpiredSession: false,
      parse: _tokenFrom,
    );
    await _secureStorage.saveToken(token);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<void>(
        '/api/Auth/logout',
        unauthorizedIsExpiredSession: false,
        parse: (_) {},
      );
    } finally {
      await _secureStorage.deleteToken();
    }
  }

  /// Answers whether the stored token still works, without bouncing the user
  /// to the login screen: this runs while the app is deciding which screen to
  /// show, so it handles a rejected token itself.
  Future<bool> checkLoggedIn() async {
    if (await _secureStorage.getToken() == null) return false;
    try {
      final token = await _apiClient.get<String>(
        '/api/Auth/status',
        unauthorizedIsExpiredSession: false,
        parse: _tokenFrom,
      );
      await _secureStorage.saveToken(token);
      return true;
    } on ApiException {
      await _secureStorage.deleteToken();
      return false;
    }
  }

  /// Registration answers `{ message, data: { id } }` — an id, not a token — so
  /// the account is signed in afterwards with the credentials just used.
  Future<void> register(
    String email,
    String password,
    String displayName,
    String firstName,
    String lastName,
    String birthDate,
    File image,
  ) async {
    final imageBytes = await image.readAsBytes();

    await _apiClient.post<void>(
      '/api/Customer/Register',
      authenticated: false,
      body: <String, dynamic>{
        'displayName': displayName,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate,
        'image': base64Encode(imageBytes),
        'email': email,
        'password': password,
      },
      parse: (_) {},
    );
  }

  Future<void> deleteAccount() async {
    await _apiClient.delete('/api/User/Delete');
    await _secureStorage.deleteToken();
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

  Future<void> loginWithGoogle() async {
    if (!config.AppConfig.isGoogleSignInConfigured) {
      throw ApiException(
        0,
        'Google sign-in is unavailable: this build was made without '
        'GOOGLE_SERVER_CLIENT_ID.',
      );
    }
    await _secureStorage.deleteToken();

    final GoogleSignInAccount googleUser;
    final GoogleSignInClientAuthorization authorization;
    try {
      await _ensureGoogleSignInInitialized();

      // Throws GoogleSignInException instead of returning null when the user
      // cancels, so the old `googleUser == null` check becomes this catch.
      googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: _googleScopes,
      );

      // 7.x moved the access token off GoogleSignInAuthentication; it now comes
      // from the authorization client, which the server contract still needs.
      authorization =
          await googleUser.authorizationClient.authorizationForScopes(
            _googleScopes,
          ) ??
          await googleUser.authorizationClient.authorizeScopes(_googleScopes);
    } on GoogleSignInException catch (error) {
      throw ApiException(
        0,
        error.code == GoogleSignInExceptionCode.canceled
            ? 'Google sign-in was cancelled.'
            : 'Google sign-in failed: ${error.description ?? error.code.name}',
      );
    } catch (error) {
      throw ApiException(
        0,
        'Google sign-in could not start on this device: $error',
      );
    }

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final token = await _apiClient.post<String>(
      '/api/Auth/google-login',
      body: <String, dynamic>{
        'IdToken': googleAuth.idToken,
        'AccessToken': authorization.accessToken,
      },
      authenticated: false,
      unauthorizedIsExpiredSession: false,
      parse: _tokenFrom,
    );
    await _secureStorage.saveToken(token);
  }

  /// Registering as a partner returns a fresh token, because the role inside
  /// the old one is now wrong.
  Future<void> registerPartner(Map<String, dynamic> partner) async {
    final token = await _apiClient.post<String>(
      '/api/Partner/Add',
      body: partner,
      parse: _tokenFrom,
    );
    await _secureStorage.saveToken(token);
  }

  Future<String> roleCheck() async {
    final token = await _secureStorage.getToken();
    if (token == null) return '';

    final claims = _claimsOf(token);
    if (claims == null || _hasExpired(claims)) return '';

    final role = claims[JwtClaims.role] ?? claims[JwtClaims.shortRole];
    return role is String && Roles.all.contains(role) ? role : '';
  }

  Future<String> currentUserEmail() async {
    final token = await _secureStorage.getToken();
    if (token == null) return '';

    final claims = _claimsOf(token);
    if (claims == null || _hasExpired(claims)) return '';

    final email = claims[JwtClaims.email] ?? claims[JwtClaims.shortEmail];
    return email is String ? email : '';
  }

  Future<String> currentUserId() async {
    final token = await _secureStorage.getToken();
    if (token == null) return '';

    final claims = _claimsOf(token);
    if (claims == null || _hasExpired(claims)) return '';

    final id = claims[JwtClaims.userId] ?? claims[JwtClaims.shortUserId];
    return id is String ? id : '';
  }

  static Map<String, dynamic>? _claimsOf(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final decoded = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  static bool _hasExpired(Map<String, dynamic> claims) {
    final expiry = claims[JwtClaims.expiry];
    if (expiry is! num) return false;

    return DateTime.fromMillisecondsSinceEpoch(
      expiry.toInt() * 1000,
      isUtc: true,
    ).isBefore(DateTime.now().toUtc());
  }
}
