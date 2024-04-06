import 'package:flutter/foundation.dart';
import 'package:ebooking/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> checkLoggedInStatus() async {
    _isLoggedIn = await _authService.checkLoggedIn();
    notifyListeners();
    return _isLoggedIn;
  }

  /*START LOGIN FUNCTION*/
  Future<bool> login(String email, String password) async {
    bool success = await _authService.login(email, password);
    _isLoggedIn = success;
    notifyListeners();
    return success;
  }

   Future<bool> loginWithFacebook() async {
    bool success = await _authService.loginWithFacebook();
    _isLoggedIn = success;
    notifyListeners();
    return success;
  }
  /*END LOGIN FUNCTION*/

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
