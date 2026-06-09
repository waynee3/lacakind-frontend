import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/data/models/device_model.dart';

class DeviceRepository {
  final _dio = ApiClient.dio;

  Future<(List<DeviceModel>?, String?)> getDevices({
    String? serialNumber,
    String? status,
    String? modelType,
    String? location,
    int page = 1,
  }) async {
    final (res, error) = await ApiClient.safeCall(
      () => _dio.get('/devices', queryParameters: {
        if (serialNumber != null) 'serialNumber': serialNumber,
        if (status != null) 'status': status,
        if (modelType != null) 'modelType': modelType,
        if (location != null) 'location': location,
        'page': page,
      }),
    );
    if (error != null) return (null, error);
    final devices = (res!.data as List)
        .map((e) => DeviceModel.fromJson(e))
        .toList();
    return (devices, null);
  }

  Future<String?> addDevice(Map<String, dynamic> data) async {
    final (_, error) = await ApiClient.safeCall(
      () => _dio.post('/devices', data: data),
    );
    return error;
  }

  Future<String?> updateDevice(String id, Map<String, dynamic> data) async {
    final (_, error) = await ApiClient.safeCall(
      () => _dio.put('/devices/$id', data: data),
    );
    return error;
  }

  Future<String?> deleteDevice(String id) async {
    final (_, error) = await ApiClient.safeCall(
      () => _dio.delete('/devices/$id'),
    );
    return error;
  }

  Future<String?> bulkLifecycleEvent(
    List<String> deviceIds,
    Map<String, dynamic> data,
  ) async {
    final (_, error) = await ApiClient.safeCall(
      () => _dio.post('/devices/bulk/lifecycle', data: {
        'deviceIds': deviceIds,
        ...data,
      }),
    );
    return error;
  }
}