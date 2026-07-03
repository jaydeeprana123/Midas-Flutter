import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:midas/app/constants/app_menu_config.dart';
import 'package:midas/app/routes/app_routes.dart';
import 'package:midas/data/models/app_permission.dart';
import 'package:midas/data/repositories/auth_repository.dart';
import 'package:midas/data/services/api_client.dart';
import 'package:midas/data/services/secure_storage_service.dart';
import 'package:midas/presentation/widgets/logout_confirmation_dialog.dart';

class HomeController extends GetxController {
  HomeController({
    required this.authRepository,
    required this.secureStorage,
    required this.apiClient,
  });

  final AuthRepository authRepository;
  final SecureStorageService secureStorage;
  final ApiClient apiClient;

  final selectedTab = 0.obs;
  final isLoggingOut = false.obs;
  final assetMenuItems = <AppMenuItem>[].obs;
  final equipmentMenuItems = <AppMenuItem>[].obs;
  final drawerMenuItems = <AppMenuItem>[].obs;

  bool get showAssetsTab => assetMenuItems.isNotEmpty;
  bool get showEquipmentsTab => equipmentMenuItems.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final permissions = await secureStorage.getPermissions();
    _applyPermissions(permissions);
  }

  void _applyPermissions(List<AppPermission> permissions) {
    final labels = permissions
        .map((permission) => permission.label.trim().toLowerCase())
        .toSet();

    assetMenuItems.assignAll(
      AppMenuConfig.visibleItems(
        labels,
        section: AppMenuSection.assets,
        homeOnly: true,
      ),
    );
    equipmentMenuItems.assignAll(
      AppMenuConfig.visibleItems(
        labels,
        section: AppMenuSection.equipments,
        homeOnly: true,
      ),
    );
    drawerMenuItems.assignAll(
      AppMenuConfig.visibleItems(labels, drawerOnly: true),
    );

    if (!showAssetsTab && showEquipmentsTab) {
      selectedTab.value = 1;
    } else if (showAssetsTab) {
      selectedTab.value = 0;
    }
  }

  void onTabChanged(int index) {
    selectedTab.value = index;
  }

  Future<void> onLogoutTap() async {
    final confirmed = await showLogoutConfirmationDialog();
    if (confirmed != true) return;

    isLoggingOut.value = true;
    try {
      final response = await authRepository.logout();
      if (_isSuccess(response)) {
        await _completeLogout();
        return;
      }
      Get.snackbar(
        'Logout Failed',
        (response['message'] ?? 'Unable to logout.').toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        Get.snackbar(
          'Logout Failed',
          responseData['message'].toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Logout Failed',
          'Unable to logout. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Logout Failed',
        'Unable to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoggingOut.value = false;
    }
  }

  Future<void> _completeLogout() async {
    final version = (Get.arguments?['version'] ?? '').toString();
    final orgLabel = (Get.arguments?['orgLabel'] ?? '').toString();

    await secureStorage.clearSession();
    apiClient.setAuthToken(null);

    Get.offAllNamed(
      AppRoutes.login,
      arguments: {'version': version, 'orgLabel': orgLabel},
    );
  }

  bool _isSuccess(Map<String, dynamic> response) {
    return response['isSuccess'] == true || response['status'] == 200;
  }
}
