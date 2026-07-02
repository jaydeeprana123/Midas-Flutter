import 'package:midas/data/services/api_client.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String macAddress,
  }) {
    return _apiClient.post(
      '/api/Login/LoginAuthentication',
      queryParameters: {
        'Username': username,
        'Password': password,
        'MacAddress': macAddress,
      },
    );
  }
}
