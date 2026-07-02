import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  LocalStorageService(this._box);

  final GetStorage _box;

  static const _keyBaseUrl = 'baseUrl';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';

  String? get baseUrl => _box.read<String>(_keyBaseUrl);
  String? get username => _box.read<String>(_keyUsername);
  String? get password => _box.read<String>(_keyPassword);

  Future<void> saveBaseUrl(String url) => _box.write(_keyBaseUrl, url);

  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _box.write(_keyUsername, username);
    await _box.write(_keyPassword, password);
  }
}
