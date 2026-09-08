import 'package:flutter/foundation.dart';

import 'package:ebooking_desktop/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  bool _isLoggedIn = false;
  String _role = '';

  AuthProvider({required AuthService authService}) : _authService = authService;

  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;
  bool get isAdministrator => _role == 'Administrator';

  Future<bool> checkLoggedInStatus() async {
    _isLoggedIn = await _authService.checkLoggedIn();
    notifyListeners();
    return _isLoggedIn;
  }

  /// Vraća (success, message) da UI može prikazati konkretan razlog neuspjeha.
  Future<LoginResult> login(String email, String password) async {
    final result = await _authService.login(email, password);
    _isLoggedIn = result.success;
    if (result.success) {
      _role = await _authService.roleCheck();
    }
    notifyListeners();
    return result;
  }

  Future<LogoutResult> logout() async {
    final result = await _authService.logout();
    _isLoggedIn = false;
    _role = '';
    notifyListeners();
    return result;
  }

  Future<String> roleCheck() async {
    _role = await _authService.roleCheck();
    return _role;
  }
}
