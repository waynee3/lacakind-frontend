import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/data/models/contract_model.dart';

class ContractRepository {
  final _dio = ApiClient.dio;

  static const int pageSize = 20;

  Future<(List<ContractModel>?, String?)> getAllContracts() async {
    final (res, error) = await ApiClient.safeCall(
      () => _dio.get('/contracts', queryParameters: {'limit': 999, 'page': 1}),
    );
    if (error != null) return (null, error);
    final contracts = (res!.data as List)
        .map((e) => ContractModel.fromJson(e))
        .toList();
    return (contracts, null);
  }

  Future<(List<ContractModel>?, String?)> getContracts({
    String? contractId,
    String? clientName,
    String? contractType,
    String? startDate,
    String? endDate,
    String? status,
    String? paymentStatus,
    int page = 1,
  }) async {
    final (res, error) = await ApiClient.safeCall(
      () => _dio.get(
        '/contracts',
        queryParameters: {
          'contractId':    ?contractId,
          'clientName':    ?clientName,
          'contractType':  ?contractType,
          'startDate':     ?startDate,
          'endDate':       ?endDate,
          'status':        ?status,
          'paymentStatus': ?paymentStatus,
          'page':          page,
          'limit':         pageSize,
        },
      ),
    );
    if (error != null) return (null, error);
    final contracts = (res!.data as List)
        .map((e) => ContractModel.fromJson(e))
        .toList();
    return (contracts, null);
  }

  Future<(ContractModel?, String?)> getContractById(String id) async {
    final (res, error) = await ApiClient.safeCall(
      () => _dio.get('/contracts/$id'),
    );
    if (error != null) return (null, error);
    return (ContractModel.fromJson(res!.data), null);
  }

  Future<ContractModel> addContract(Map<String, dynamic> data) async {
    final res = await _dio.post('/contracts', data: data);
    return ContractModel.fromJson(res.data);
  }

  Future<ContractModel> updateContract(
    String id,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.put('/contracts/$id', data: data);
    return ContractModel.fromJson(res.data);
  }

  Future<String?> deleteContract(String id) async {
    final (_, error) = await ApiClient.safeCall(
      () => _dio.delete('/contracts/$id'),
    );
    return error;
  }
}