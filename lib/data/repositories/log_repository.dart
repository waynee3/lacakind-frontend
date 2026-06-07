import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/data/models/log_model.dart';

class LogRepository {
  final _dio = ApiClient.dio;

  Future<List<LogModel>> getLogs(String deviceSerial) async {
    final res = await _dio.get('/logs', queryParameters: {
      'deviceSerial': deviceSerial,
    });
    return (res.data as List).map((e) => LogModel.fromJson(e)).toList();
  }

  Future<void> addLog(String serialNumber, Map<String, dynamic> data) async {
    await _dio.post('/logs/$serialNumber', data: data);
  }

  Future<void> updateLog({
    required String deviceId,
    required int logIndex,
    required Map<String, dynamic> data,
  }) async {
    await _dio.put('/logs', queryParameters: {
      'deviceId': deviceId,
      'logIndex': logIndex,
    }, data: data);
  }

  Future<void> deleteLog({
    required String deviceId,
    required int logIndex,
  }) async {
    await _dio.delete('/logs', queryParameters: {
      'deviceId': deviceId,
      'logIndex': logIndex,
    });
  }
}