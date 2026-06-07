import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/core/token_storage.dart';

class AuthRepository {
  final _dio = ApiClient.dio;

  Future<String> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = res.data['token'] as String;
    await TokenStorage.save(token);
    return token;
  }

  Future<void> register(String email, String password) async {
    await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
    });
  }

  Future<void> logout() => TokenStorage.clear();

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.read();
    return token != null;
  }
}