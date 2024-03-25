// `import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;

// class AuthProvider with ChangeNotifier {
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   bool _isLoggedIn = false;

//   bool get isLoggedIn => _isLoggedIn;

//   Future<void> checkLoggedInStatus() async {
//     String? token = await _secureStorage.read(key: 'jwt_token');
//     if (token != null) {
//       // Here you might also add logic to check if the token is expired.
//       _isLoggedIn = true;
//     } else {
//       _isLoggedIn = false;
//     }
//     notifyListeners();
//   }

//   Future<bool> login(String email, String password) async {
//     final url = Uri.parse('https://localhost:7140/api/Login/customer');
//     final response = await http.post(url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'email': email, 'password': password}));

//     if (response.statusCode == 200) {
//       _isLoggedIn = true;
//       await _secureStorage.write(key: 'jwt_key', value: response.body);
//       notifyListeners();
//       return true;
//     } else {
//       _isLoggedIn = false;
//       return false;
//     }
//   }

//   Future<void> logout() async {
//     await _secureStorage.delete(key: 'jwt_token');
//     _isLoggedIn = false;
//     notifyListeners();
//   }
// }
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoggedInStatus() async {
    String? token = await _secureStorage.read(key: 'jwt_token');
    if (token != null) {
      // Here you might also add logic to check if the token is expired.
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('https://localhost:7140/api/Login/customer');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}));

    if (response.statusCode == 200) {
      _isLoggedIn = true;
      await _secureStorage.write(key: 'jwt_key', value: response.body);
      notifyListeners();
      return true;
    } else {
      _isLoggedIn = false;
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    return true;
    }


  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    _isLoggedIn = false;
    notifyListeners();
  }
}


