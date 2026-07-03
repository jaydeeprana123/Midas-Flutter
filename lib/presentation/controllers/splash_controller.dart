import 'package:get/get.dart';
import 'package:midas/app/routes/app_routes.dart';
import 'package:midas/data/repositories/system_repository.dart';
import 'package:midas/data/services/api_client.dart';
import 'package:midas/data/services/secure_storage_service.dart';

class SplashController extends GetxController {
  SplashController({
    required SystemRepository systemRepository,
    required SecureStorageService secureStorage,
    required ApiClient apiClient,
  })  : _systemRepository = systemRepository,
        _secureStorage = secureStorage,
        _apiClient = apiClient;

  final SystemRepository _systemRepository;
  final SecureStorageService _secureStorage;
  final ApiClient _apiClient;

  @override
  Future<void> onReady() async {
    super.onReady();
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    var version = '';
    var orgLabel = '';

    try {
      final orgInfo = await _systemRepository.fetchSystemVersionAndLabel();
      version = orgInfo.version;
      orgLabel = orgInfo.organizationLabel;
    } catch (_) {}

    final hasSession = await _secureStorage.hasActiveSession();
    if (hasSession) {
      final savedToken = await _secureStorage.token;
      final savedOrgLabel = await _secureStorage.orgLabel;
      if (savedToken != null && savedToken.isNotEmpty) {
        _apiClient.setAuthToken(savedToken);
      }
      Get.offAllNamed(
        AppRoutes.home,
        arguments: {
          'version': version,
          'orgLabel': (savedOrgLabel ?? orgLabel).isNotEmpty
              ? (savedOrgLabel ?? orgLabel)
              : orgLabel,
        },
      );
      return;
    }

    Get.offAllNamed(
      AppRoutes.login,
      arguments: {'version': version, 'orgLabel': orgLabel},
    );
  }
}
