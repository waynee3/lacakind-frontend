import 'package:dio/dio.dart';
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
        'serialNumber': ?serialNumber,
        'status': ?status,
        'modelType': ?modelType,
        'location': ?location,
        'page': page,
      }),
    );
    if (error != null) return (null, error);
    final devices = (res!.data as List)
        .map((e) => DeviceModel.fromJson(e))
        .toList();
    return (devices, null);
  }

  Future<(DeviceModel?, String?)> getDeviceById(String id) async {
    final (res, error) = await ApiClient.safeCall(
      () => _dio.get('/devices/$id'),
    );
    if (error != null) return (null, error);
    return (DeviceModel.fromJson(res!.data), null);
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

  /// Imports devices from a CSV file (multipart/form-data).
  /// Returns (successCount, errors, fatalError).
  Future<({int? inserted, List<String> errors, String? fatalError})>
      importDevices(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'csvFile': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final (res, error) = await ApiClient.safeCall(
        () => _dio.post('/utilities/bulk-import', data: formData),
      );
      if (error != null) return (inserted: null, errors: [error], fatalError: error);
      final data = res!.data as Map<String, dynamic>;
      final rawErrors = data['errors'];
      final errors = rawErrors is List
          ? List<String>.from(rawErrors.map((e) => e.toString()))
          : <String>[];
      return (
        inserted: data['successfulRecords'] as int?,
        errors: errors,
        fatalError: null,
      );
    } catch (e) {
      return (inserted: null, errors: [e.toString()], fatalError: e.toString());
    }
  }
}