import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/data/models/client_model.dart';

class ClientRepository {
  final _dio = ApiClient.dio;

  Future<List<ClientModel>> getClients({String? search}) async {
    final res = await _dio.get('/clients', queryParameters: {
      'search': ?search,
    });
    return (res.data as List).map((e) => ClientModel.fromJson(e)).toList();
  }

  Future<ClientModel> addClient(Map<String, dynamic> data) async {
    final res = await _dio.post('/clients', data: data);
    return ClientModel.fromJson(res.data);
  }

  Future<ClientModel> updateClient(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/clients/$id', data: data);
    return ClientModel.fromJson(res.data);
  }

  Future<void> deleteClient(String id) async {
    await _dio.delete('/clients/$id');
  }
}