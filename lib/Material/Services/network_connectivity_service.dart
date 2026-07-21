import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkConnectivityService extends GetxService {
  NetworkConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  final isOnline = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await refresh();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      isOnline.value = _hasConnection(results);
    });
  }

  Future<bool> refresh() async {
    final results = await _connectivity.checkConnectivity();
    isOnline.value = _hasConnection(results);
    return isOnline.value;
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
