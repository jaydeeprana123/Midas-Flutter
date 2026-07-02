import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/app/routes/app_routes.dart';
import 'package:midas/data/models/app_domain.dart';
import 'package:midas/data/repositories/auth_repository.dart';
import 'package:midas/data/repositories/system_repository.dart';
import 'package:midas/data/services/api_client.dart';
import 'package:midas/data/services/device_service.dart';
import 'package:midas/data/services/local_storage_service.dart';

class LoginController extends GetxController {
  LoginController({
    required this.authRepository,
    required this.systemRepository,
    required this.deviceService,
    required this.storageService,
    required this.apiClient,
  });

  final AuthRepository authRepository;
  final SystemRepository systemRepository;
  final DeviceService deviceService;
  final LocalStorageService storageService;
  final ApiClient apiClient;

  final usernameController = TextEditingController(text: 'gsspl');
  final passwordController = TextEditingController(text: 'Admin\$1234');
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final version = ''.obs;
  final orgLabel = ''.obs;
  final macAddress = ''.obs;
  final selectedDomain = ''.obs;

  @override
  void onInit() {
    super.onInit();
    version.value = (Get.arguments?['version'] ?? '').toString();
    orgLabel.value = (Get.arguments?['orgLabel'] ?? '').toString();
    selectedDomain.value =
        storageService.baseUrl ?? apiClient.dio.options.baseUrl;
  }

  @override
  Future<void> onReady() async {
    super.onReady();

    macAddress.value = "f907f6a426868d43";

    // macAddress.value = await deviceService.getMacOrDeviceId();
  }

  Future<void> onLogin() async {
    isLoading.value = true;
    try {
      await authRepository.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
        macAddress: macAddress.value,
      );
      await storageService.saveCredentials(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(
        AppRoutes.home,
        arguments: {'orgLabel': orgLabel.value, 'version': version.value},
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        Get.snackbar(
          'Login Failed',
          responseData['message'].toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Login Failed',
          'Invalid username or password.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Login Failed',
        'Unable to login. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<AppDomain>> fetchDomains() => systemRepository.fetchDomains();

  Future<void> saveDomain(String url) async {
    final normalized = url.endsWith('/') ? url : '$url/';
    await storageService.saveBaseUrl(normalized);
    apiClient.setBaseUrl(normalized);
    selectedDomain.value = normalized;
    try {
      final org = await systemRepository.fetchSystemVersionAndLabel();
      version.value = org.version;
      orgLabel.value = org.organizationLabel;
    } catch (_) {}
  }
}
