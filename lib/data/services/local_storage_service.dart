import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  LocalStorageService(this._box);

  final GetStorage _box;

  static const _keyBaseUrl = 'baseUrl';

  String? get baseUrl => _box.read<String>(_keyBaseUrl);

  Future<void> saveBaseUrl(String url) => _box.write(_keyBaseUrl, url);
}
