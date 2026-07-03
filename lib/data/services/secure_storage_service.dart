import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:midas/data/models/app_permission.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _keyToken = 'token';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyOrgLabel = 'orgLabel';
  static const _keyPermissions = 'permissions';

  Future<String?> get token => _storage.read(key: _keyToken);

  Future<String?> get username => _storage.read(key: _keyUsername);

  Future<String?> get password => _storage.read(key: _keyPassword);

  Future<String?> get orgLabel => _storage.read(key: _keyOrgLabel);

  Future<bool> hasActiveSession() async {
    final savedToken = await token;
    return savedToken != null && savedToken.isNotEmpty;
  }

  Future<void> saveSession({
    required String token,
    required String username,
    required String password,
    required String orgLabel,
    List<AppPermission> permissions = const [],
  }) async {
    await Future.wait([
      _storage.write(key: _keyToken, value: token),
      _storage.write(key: _keyUsername, value: username),
      _storage.write(key: _keyPassword, value: password),
      _storage.write(key: _keyOrgLabel, value: orgLabel),
      savePermissions(permissions),
    ]);
  }

  Future<void> savePermissions(List<AppPermission> permissions) {
    final encoded = jsonEncode(permissions.map((item) => item.toJson()).toList());
    return _storage.write(key: _keyPermissions, value: encoded);
  }

  Future<List<AppPermission>> getPermissions() async {
    final raw = await _storage.read(key: _keyPermissions);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => AppPermission.fromJson(Map<String, dynamic>.from(item)))
        .where((permission) => permission.isActive)
        .toList();
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyToken),
      _storage.delete(key: _keyUsername),
      _storage.delete(key: _keyPassword),
      _storage.delete(key: _keyOrgLabel),
      _storage.delete(key: _keyPermissions),
    ]);
  }
}
