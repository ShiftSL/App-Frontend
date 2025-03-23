import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  // Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Save user as JSON string
  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  // Get user JSON string
  static Future<String?> getUser() async {
    return await _storage.read(key: _userKey);
  }

  // Clear all (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Generic read method
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

}
