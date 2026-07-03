import 'package:get/get.dart';
import 'package:midas/AssetTag/Controllers/asset_search_controller.dart';
import 'package:midas/AssetTag/Controllers/assign_asset_tag_controller.dart';
import 'package:midas/AssetTag/Views/asset_search_view.dart';
import 'package:midas/AssetTag/Views/assign_asset_tag_view.dart';
import 'package:midas/AssetTag/asset_repository.dart';
import 'package:midas/Auth/Controllers/login_controller.dart';
import 'package:midas/Auth/Controllers/splash_controller.dart';
import 'package:midas/Auth/Views/login_view.dart';
import 'package:midas/Auth/Views/splash_view.dart';
import 'package:midas/Auth/auth_repository.dart';
import 'package:midas/Auth/system_repository.dart';
import 'package:midas/Home/Controllers/home_controller.dart';
import 'package:midas/Home/Views/home_view.dart';
import 'package:midas/Shared/Services/api_client.dart';
import 'package:midas/Shared/Services/device_service.dart';
import 'package:midas/Shared/Services/local_storage_service.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Services/secure_storage_service.dart';
import 'package:midas/app/routes/app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(
          SplashController(
            systemRepository: Get.find<SystemRepository>(),
            secureStorage: Get.find<SecureStorageService>(),
            apiClient: Get.find<ApiClient>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => LoginController(
            authRepository: Get.find<AuthRepository>(),
            systemRepository: Get.find<SystemRepository>(),
            deviceService: Get.find<DeviceService>(),
            storageService: Get.find<LocalStorageService>(),
            secureStorage: Get.find<SecureStorageService>(),
            apiClient: Get.find<ApiClient>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => HomeController(
            authRepository: Get.find<AuthRepository>(),
            secureStorage: Get.find<SecureStorageService>(),
            apiClient: Get.find<ApiClient>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.assignAssetTag,
      page: () => const AssignAssetTagView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => AssignAssetTagController(
            assetRepository: Get.find<AssetRepository>(),
            secureStorage: Get.find<SecureStorageService>(),
            rfidService: Get.find<RfidService>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.assetSearch,
      page: () => const AssetSearchView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => AssetSearchController(
            assetRepository: Get.find<AssetRepository>(),
            secureStorage: Get.find<SecureStorageService>(),
          ),
        );
      }),
    ),
  ];
}
