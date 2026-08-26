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

  /// Vraća (success, message) da UI može prikazati konkretan razlog neuspjeha
  /// (Upute 4: false-positive i generičke poruke nisu prihvatljive).
  Future<LoginResult> login(String email, String password) async {
    final result = await _authService.login(email, password);
    _isLoggedIn = result.success;
    if (result.success) {
      _role = await _authService.roleCheck();
    }
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _role = '';
    notifyListeners();
  }

  Future<String> roleCheck() async {
    _role = await _authService.roleCheck();
    return _role;
  }
}

// UKLONJENO (Upute 8.1 — "Programski kod koji se ne koristi ne smije biti
// sastavni dio projekta"):
//   - `register(...)` — desktop je administrativni klijent, registracija se
//     radi isključivo na mobilnom klijentu. Metoda nije bila pozvana nigdje.
//   - `deleteAccount()` — nije bila pozvana ni iz jednog widgeta, a gađala je
//     `/api/Customer/Delete`, što administratorski klijent ne treba.
// Obje su povlačile `dart:io` i `File` u auth sloj bez razloga.
