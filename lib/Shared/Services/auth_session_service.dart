import 'package:get/get.dart';
import 'package:midas/Shared/Services/api_client.dart';
import 'package:midas/Shared/Services/local_storage_service.dart';
import 'package:midas/Shared/Services/secure_storage_service.dart';
import 'package:midas/app/routes/app_routes.dart';

class AuthSessionService {
  AuthSessionService({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required ApiClient apiClient,
  })  : _secureStorage = secureStorage,
        _localStorage = localStorage,
        _apiClient = apiClient;

  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final ApiClient _apiClient;

  bool _isHandlingUnauthorized = false;

  /// Clears all session/preferences and navigates to login without calling logout API.
  Future<void> handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;

    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.login || currentRoute == AppRoutes.splash) {
      return;
    }

    _isHandlingUnauthorized = true;
    try {
      _apiClient.setAuthToken(null);
      await _secureStorage.clearAll();
      await _localStorage.clearAll();

      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
}
