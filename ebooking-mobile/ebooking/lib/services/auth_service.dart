import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // This would be replaced by your actual authentication logic
  static bool isLoggedIn = false;

  static Future<bool> checkLoggedIn() async {
    // Here, you'd check persistent storage or your backend to see if the user is logged in
    return isLoggedIn;
  }
}
class SecureStorage
{
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