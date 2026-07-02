import 'package:get/get.dart';
import 'package:midas/app/routes/app_routes.dart';
import 'package:midas/data/repositories/system_repository.dart';

class SplashController extends GetxController {
  SplashController(this._systemRepository);

  final SystemRepository _systemRepository;

  @override
  Future<void> onReady() async {
    super.onReady();
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    try {
      final orgInfo = await _systemRepository.fetchSystemVersionAndLabel();
      Get.offAllNamed(
        AppRoutes.login,
        arguments: {
          'version': orgInfo.version,
          'orgLabel': orgInfo.organizationLabel,
        },
      );
    } catch (_) {
      Get.offAllNamed(AppRoutes.login, arguments: {'version': '', 'orgLabel': ''});
    }
  }
}
