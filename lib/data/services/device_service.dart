import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String> getMacOrDeviceId() async {
    final deviceId = await _deviceIdFallback();
    return _normalizeMac(deviceId);
  }

  String _normalizeMac(String value) {
    return value.replaceAll(RegExp(r'[:\-]'), '').toLowerCase();
  }

  Future<String> _deviceIdFallback() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.id;
    }
    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return info.identifierForVendor ?? 'unknown-ios-device';
    }
    return 'unknown-device';
  }
}
