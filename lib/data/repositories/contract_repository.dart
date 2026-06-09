import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/data/models/contract_model.dart';

class ContractRepository {
  final _dio = ApiClient.dio;

  Future<List<ContractModel>> getContracts({String? clientId, String? status}) async {
    final res = await _dio.get('/contracts', queryParameters: {
      'clientId': ?clientId,
      'status': ?status,
    });
    return (res.data as List).map((e) => ContractModel.fromJson(e)).toList();
  }

  Future<ContractModel> addContract(Map<String, dynamic> data) async {
    final res = await _dio.post('/contracts', data: data);
    return ContractModel.fromJson(res.data);
  }

  Future<ContractModel> updateContract(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/contracts/$id', data: data);
    return ContractModel.fromJson(res.data);
  }

  Future<void> deleteContract(String id) async {
    await _dio.delete('/contracts/$id');
  }
}