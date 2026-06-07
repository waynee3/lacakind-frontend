import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/data/models/repair_model.dart';

class RepairRepository {
  final _dio = ApiClient.dio;

  Future<List<RepairModel>> getRepairs({String? deviceSerial}) async {
    final res = await _dio.get('/repairs', queryParameters: {
      'deviceSerial': ?deviceSerial,
    });
    return (res.data as List).map((e) => RepairModel.fromJson(e)).toList();
  }

  Future<RepairModel> addRepair(Map<String, dynamic> data) async {
    final res = await _dio.post('/repairs', data: data);
    return RepairModel.fromJson(res.data);
  }

  Future<RepairModel> updateRepair(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/repairs/$id', data: data);
    return RepairModel.fromJson(res.data);
  }
}