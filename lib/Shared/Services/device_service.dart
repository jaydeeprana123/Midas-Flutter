import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  DeviceService({GetStorage? storage})
      : _storage = storage ?? GetStorage(webStorageContainer);

  /// Separate container so logout `GetStorage().erase()` does not wipe it.
  static const webStorageContainer = 'device_identity';
  static const _webDeviceIdKey = 'web_device_id';

  static Future<void> initStorage() => GetStorage.init(webStorageContainer);

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final AndroidId _androidId = const AndroidId();
  final GetStorage _storage;
  final Uuid _uuid = const Uuid();

  Future<String> getMacOrDeviceId() async {
    final deviceId = await _deviceIdFallback();
    return _normalizeMac(deviceId);
  }

  String _normalizeMac(String value) {
    return value.replaceAll(RegExp(r'[:\-]'), '').toLowerCase();
  }

  Future<String> _deviceIdFallback() async {
    if (kIsWeb) {
      return _webDeviceId();
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Settings.Secure.ANDROID_ID — unique per device (not Build.ID).
      final id = await _androidId.getId();
      if (id != null && id.isNotEmpty) {
        return id;
      }
      return 'unknown-android-device';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final info = await _deviceInfo.iosInfo;
      return info.identifierForVendor ?? 'unknown-ios-device';
    }

    return 'unknown-device';
  }

  /// Browsers cannot expose a real MAC address. Generate a UUID once and
  /// persist it in local storage so the same browser keeps the same ID.
  String _webDeviceId() {
    final existing = _storage.read<String>(_webDeviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final id = _uuid.v4().replaceAll('-', '');
    _storage.write(_webDeviceIdKey, id);
    return id;
  }
}
