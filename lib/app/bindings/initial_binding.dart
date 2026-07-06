import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:midas/AssetTag/asset_repository.dart';
import 'package:midas/Location/location_repository.dart';
import 'package:midas/Auth/auth_repository.dart';
import 'package:midas/Auth/system_repository.dart';
import 'package:midas/Shared/Services/api_client.dart';
import 'package:midas/Shared/Services/device_service.dart';
import 'package:midas/Shared/Services/local_storage_service.dart';
import 'package:midas/Shared/Services/rfid_service.dart';
import 'package:midas/Shared/Services/secure_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storage = LocalStorageService(GetStorage());
    final secureStorage = SecureStorageService();
    final baseUrl = storage.baseUrl ?? 'https://midastestbe.garimasystem.com/';
    final apiClient = ApiClient(baseUrl: baseUrl);

    Get.put<LocalStorageService>(storage, permanent: true);
    Get.put<SecureStorageService>(secureStorage, permanent: true);
    Get.put<ApiClient>(apiClient, permanent: true);
    Get.put<SystemRepository>(SystemRepository(apiClient), permanent: true);
    Get.put<AuthRepository>(AuthRepository(apiClient), permanent: true);
    Get.put<AssetRepository>(AssetRepository(apiClient), permanent: true);
    Get.put<LocationRepository>(LocationRepository(apiClient), permanent: true);
    Get.put<DeviceService>(DeviceService(), permanent: true);
    Get.put<RfidService>(RfidService(), permanent: true);
  }
}
