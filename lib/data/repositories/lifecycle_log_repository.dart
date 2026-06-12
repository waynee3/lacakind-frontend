import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/data/models/bulk_operation_model.dart';

class LifecycleLogRepository {
  final _dio = ApiClient.dio;

  static const int pageSize = 20;

  Future<(List<BulkOperationModel>?, String?)> getLogs({
    String? serialNumber,
    String? clientName,
    String? action,
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    final (res, error) = await ApiClient.safeCall(
      () => _dio.get(
        '/devices/bulk-operations',
        queryParameters: {
          if (serialNumber != null && serialNumber.isNotEmpty)
            'serialNumber': serialNumber,
          if (clientName != null && clientName.isNotEmpty)
            'clientName': clientName,
          if (action != null && action.isNotEmpty) 'action': action,
          'startDate': ?startDate,
          'endDate':   ?endDate,
          'page':  page,
          'limit': pageSize,
        },
      ),
    );
    if (error != null) return (null, error);
    final data = res!.data;
    final list = (data['bulkOperations'] ?? data) as List;
    return (
      list.map((e) => BulkOperationModel.fromJson(e)).toList(),
      null,
    );
  }
}