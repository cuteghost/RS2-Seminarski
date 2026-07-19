import 'dart:io';

import 'package:ebooking/models/partner_model.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:flutter/foundation.dart';

/// Every call that can be refused answers `(success, message)`.
///
/// `message` is whatever the API said, word for word — the screens print it
/// instead of a sentence of their own, so a user who types a password that is
/// too short reads why rather than "something went wrong".
typedef AuthResult = (bool success, String message);

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isLoggedIn = false;
  String _userId = '';
  String _role = '';
  AuthProvider({required this._authService});

  bool get isLoggedIn => _isLoggedIn;

  String get userId => _userId;

  String get role => _role;

  Future<bool> checkLoggedInStatus() async {
    _isLoggedIn = await _authService.checkLoggedIn();
    notifyListeners();
    return _isLoggedIn;
  }

  /*START LOGIN FUNCTION*/
  Future<AuthResult> login(String email, String password) {
    return _run(() => _authService.login(email, password), 'Signed in.');
  }

  Future<AuthResult> loginWithFacebook() {
    return _run(_authService.loginWithFacebook, 'Signed in.');
  }

  Future<AuthResult> loginWithGoogle() {
    return _run(_authService.loginWithGoogle, 'Signed in.');
  }
  /*END LOGIN FUNCTION*/

  Future<AuthResult> logout() async {
    AuthResult result;
    try {
      await _authService.logout();
      result = (true, 'Signed out.');
    } on ApiException catch (e) {
      result = e.statusCode == 401
          ? (true, 'Signed out.')
          : (
              false,
              'Signed out on this device, but the server did not confirm it, '
                  'so the session may still be open elsewhere. ${e.message}',
            );
    }
    clearSession();
    return result;
  }

  void clearSession() {
    _isLoggedIn = false;
    _userId = '';
    _role = '';
    notifyListeners();
  }

  /*START REGISTER FUNCTION*/

  /// Registration answers with an id, not a token: creating the account does
  /// not sign anyone in, and the screen sends the new user to the login form.
  Future<AuthResult> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String displayName,
    File image,
    String birthDate,
  ) {
    return _run(
      () => _authService.register(
        email,
        password,
        displayName,
        firstName,
        lastName,
        birthDate,
        image,
      ),
      'Your account is ready. Please sign in.',
      updatesSession: false,
    );
  }

  /// Not a sign-in: the user is already signed in and stays signed in whether
  /// the partner registration is accepted or refused.
  Future<AuthResult> registerPartner(Partner partner) {
    return _run(
      () => _authService.registerPartner(partner.toJson()),
      'You are registered as a partner.',
      updatesSession: false,
    );
  }
  /*END REGISTER FUNCTION*/

  /// Throws when the server refuses the delete. The old `void` signature
  /// dropped both the wait and the error, so the caller navigated to the
  /// login screen while the account was still there.
  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    clearSession();
  }

  Future<String> currentEmail() => _authService.currentUserEmail();

  Future<String> roleCheck() async {
    _userId = await _authService.currentUserId();
    _role = await _authService.roleCheck();
    return _role;
  }

  Future<AuthResult> _run(
    Future<void> Function() action,
    String successMessage, {
    bool updatesSession = true,
  }) async {
    try {
      await action();
      if (updatesSession) _isLoggedIn = true;
      notifyListeners();
      return (true, successMessage);
    } on ApiException catch (e) {
      if (updatesSession) _isLoggedIn = false;
      notifyListeners();
      return (false, e.message);
    }
  }
}
