import 'dart:convert';

import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/core/token_storage.dart';

class AuthRepository {
  final _dio = ApiClient.dio;

  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required';
    }
    final (res, error) = await ApiClient.safeCall(
      () => _dio.post('/auth/login', data: {'email': email, 'password': password}),
    );
    if (error != null) return error;
    await TokenStorage.save(res!.data['token']);
    return null;
  }

  Future<void> logout() => TokenStorage.clear();

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.read();
    return token != null;
  }

  Future<String?> currentEmail() async {
    final token = await TokenStorage.read();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      payload = payload.padRight((payload.length + 3) & ~3, '=');
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      return map['email'] as String?;
    } catch (_) {
      return null;
    }
  }
}