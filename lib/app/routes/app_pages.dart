import 'package:get/get.dart';
import 'package:midas/app/routes/app_routes.dart';
import 'package:midas/data/repositories/auth_repository.dart';
import 'package:midas/data/repositories/system_repository.dart';
import 'package:midas/data/services/api_client.dart';
import 'package:midas/data/services/device_service.dart';
import 'package:midas/data/services/local_storage_service.dart';
import 'package:midas/presentation/controllers/home_controller.dart';
import 'package:midas/presentation/controllers/login_controller.dart';
import 'package:midas/presentation/controllers/splash_controller.dart';
import 'package:midas/presentation/views/home_view.dart';
import 'package:midas/presentation/views/login_view.dart';
import 'package:midas/presentation/views/splash_view.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController(Get.find<SystemRepository>()));
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
            apiClient: Get.find<ApiClient>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
  ];
}
