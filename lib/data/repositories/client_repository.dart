import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/data/models/client_model.dart';

class ClientRepository {
  final _dio = ApiClient.dio;

  static const int pageSize = 20;

Future<(List<ClientModel>?, String?)> getAllClients() async {
  final (res, error) = await ApiClient.safeCall(
    () => _dio.get('/clients', queryParameters: {'limit': 999}),
  );
  if (error != null) return (null, error);
  return (
    (res!.data as List).map((e) => ClientModel.fromJson(e)).toList(),
    null,
  );
}

  Future<(List<ClientModel>?, String?)> getClients({
    String? clientName,
    String? email,
    String? phone,
    String? location,
    String? contactPerson,
    int page = 1,
  }) async {
    final (res, error) = await ApiClient.safeCall(
      () => _dio.get(
        '/clients',
        queryParameters: {
          'clientName': ?clientName,
          'email': ?email,
          'phone': ?phone,
          'location': ?location,
          'contactPerson': ?contactPerson,
          'page': page,
          'limit': pageSize,
        },
      ),
    );
    if (error != null) return (null, error);
    final clients = (res!.data as List)
        .map((e) => ClientModel.fromJson(e))
        .toList();
    return (clients, null);
  }

  Future<(ClientModel?, String?)> getClientById(String id) async {
    final (res, error) = await ApiClient.safeCall(
      () => _dio.get('/clients/$id'),
    );
    if (error != null) return (null, error);
    return (ClientModel.fromJson(res!.data), null);
  }

  Future<ClientModel> addClient(Map<String, dynamic> data) async {
    final res = await _dio.post('/clients', data: data);
    return ClientModel.fromJson(res.data);
  }

  Future<ClientModel> updateClient(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/clients/$id', data: data);
    return ClientModel.fromJson(res.data);
  }

  Future<String?> deleteClient(String id) async {
    final (_, error) = await ApiClient.safeCall(
      () => _dio.delete('/clients/$id'),
    );
    return error;
  }
}
