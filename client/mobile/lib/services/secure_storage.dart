import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  static String? _cached;

  Future<void> saveToken(String token) async {
    _cached = token;
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return _cached ??= await _storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    _cached = null;
    await _storage.delete(key: 'jwt_token');
  }
}
