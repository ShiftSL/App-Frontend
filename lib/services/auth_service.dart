import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import '../utils/constants/api_constants.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<bool> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final loginResponse = LoginResponse.fromJson(data);

      await _storage.write(key: 'token', value: loginResponse.token);
      await _storage.write(key: 'user', value: json.encode(loginResponse.user.toJson()));
      return true;
    } else {
      return false;
    }
  }

  static Future<String?> getToken() => _storage.read(key: 'token');
  static Future<void> logout() async => await _storage.deleteAll();
}
