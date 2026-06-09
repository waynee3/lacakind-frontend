import 'package:dio/dio.dart';
import 'package:lacakind_frontend/core/env.dart';
import 'package:lacakind_frontend/core/token_storage.dart';
import 'package:lacakind_frontend/routes/routes.dart';

class ApiClient {
  static late final Dio _dio;

  static void init() {
    _dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.read();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await TokenStorage.clear();
          router.go('/login');
        }
        return handler.next(error);
      },
    ));
  }

  static Dio get dio => _dio;

  // Returns (data, errorMessage)
  // data is null if error, errorMessage is null if success
  static Future<(T?, String?)> safeCall<T>(Future<T> Function() call) async {
    try {
      final data = await call();
      return (data, null);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response!.data['message'] ?? 'Request failed'
          : e.message ?? 'Request failed';
      return (null, message as String);
    } catch (e) {
      return (null, e.toString());
    }
  }
}