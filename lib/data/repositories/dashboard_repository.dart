import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/data/models/dashboard_model.dart';

class DashboardRepository {
  final _dio = ApiClient.dio;

  Future<(DashboardModel?, String?)> getStats() async {
    final (res, error) = await ApiClient.safeCall(
      () => _dio.get('/dashboard/stats'),
    );
    if (error != null) return (null, error);
    return (DashboardModel.fromJson(res!.data as Map<String, dynamic>), null);
  }
}