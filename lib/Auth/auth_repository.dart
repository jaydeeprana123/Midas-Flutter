import 'package:midas/Auth/Models/login_request_model.dart';
import 'package:midas/Auth/Models/login_response_model.dart';
import 'package:midas/Shared/Services/api_client.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final json = await _apiClient.post(
      '/api/Login/LoginAuthentication',
      queryParameters: request.toJson(),
    );
    return LoginResponseModel.fromJson(json);
  }

  Future<Map<String, dynamic>> logout() {
    return _apiClient.get('/api/Login/Logout');
  }
}
