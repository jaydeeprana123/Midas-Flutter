import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/app/routes/app_routes.dart';
import 'package:midas/data/models/app_domain.dart';
import 'package:midas/data/models/app_permission.dart';
import 'package:midas/data/repositories/auth_repository.dart';
import 'package:midas/data/repositories/system_repository.dart';
import 'package:midas/data/services/api_client.dart';
import 'package:midas/data/services/device_service.dart';
import 'package:midas/data/services/local_storage_service.dart';
import 'package:midas/data/services/secure_storage_service.dart';

class LoginController extends GetxController {
  LoginController({
    required this.authRepository,
    required this.systemRepository,
    required this.deviceService,
    required this.storageService,
    required this.secureStorage,
    required this.apiClient,
  });

  final AuthRepository authRepository;
  final SystemRepository systemRepository;
  final DeviceService deviceService;
  final LocalStorageService storageService;
  final SecureStorageService secureStorage;
  final ApiClient apiClient;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
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
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final savedUsername = await secureStorage.username;
    final savedPassword = await secureStorage.password;
    if (savedUsername != null && savedUsername.isNotEmpty) {
      usernameController.text = savedUsername;
    } else {
      usernameController.text = 'gsspl';
    }
    if (savedPassword != null && savedPassword.isNotEmpty) {
      passwordController.text = savedPassword;
    } else {
      passwordController.text = 'Admin\$1234';
    }
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
      final loginResponse = await authRepository.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
        macAddress: macAddress.value,
      );
      final token = _extractToken(loginResponse);
      if (token == null) {
        Get.snackbar(
          'Login Failed',
          'Authentication token not received.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final resolvedOrgLabel =
          _extractOrgLabel(loginResponse) ?? orgLabel.value;
      final permissions = AppPermission.listFromLoginResponse(loginResponse);

      await secureStorage.saveSession(
        token: token,
        username: usernameController.text.trim(),
        password: passwordController.text,
        orgLabel: resolvedOrgLabel,
        permissions: permissions,
      );
      apiClient.setAuthToken(token);

      Get.offAllNamed(
        AppRoutes.home,
        arguments: {'orgLabel': resolvedOrgLabel, 'version': version.value},
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

  String? _extractToken(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      final token = data['token'] ?? data['Token'];
      if (token != null && token.toString().isNotEmpty) {
        return token.toString();
      }
    }
    return null;
  }

  String? _extractOrgLabel(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      final label =
          data['name'] ??
          data['organizationName'] ??
          data['OrganizationName'] ??
          data['orgLabel'];
      if (label != null && label.toString().isNotEmpty) {
        return label.toString();
      }
    }
    return null;
  }
}
