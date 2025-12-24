import 'dart:io';

import 'package:ebooking/models/partner_model.dart';
import 'package:flutter/foundation.dart';
import 'package:ebooking/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isLoggedIn = false;
  AuthProvider({required AuthService authService}) : _authService = authService;

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

  /*START REGISTER FUNCTION*/
  Future<bool> register(String email, String password, String firstName, String lastName, String displayName, File image, String birthDate) async {
    bool success = await _authService.register(email, password, displayName, firstName, lastName, birthDate, image);
    _isLoggedIn = success;
    notifyListeners();
    return success;
  }

  void deleteAccount() {
    _authService.deleteAccount();
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<bool> loginWithGoogle() async{
    bool success = await _authService.loginWithGoogle();
    _isLoggedIn = success;
    notifyListeners();
    return success;

  }

  Future<bool> registerPartner(Partner partner) async {
    return await _authService.registerPartner(partner);
  }

  Future<String> roleCheck() async {
    return await _authService.roleCheck();
  }
  /*END REGISTER FUNCTION*/

}
