import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/AssetTag/Models/asset_link_tag_model.dart';
import 'package:midas/AssetTag/asset_repository.dart';
import 'package:midas/Shared/Services/secure_storage_service.dart';

class AssetSearchController extends GetxController {
  AssetSearchController({
    required this.assetRepository,
    required this.secureStorage,
  });

  final AssetRepository assetRepository;
  final SecureStorageService secureStorage;

  final searchController = TextEditingController();
  final results = <AssetLinkTagModel>[].obs;
  final isLoading = false.obs;
  final hasQuery = false.obs;

  int _orgId = 0;
  Timer? _debounce;
  int _requestToken = 0;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  Future<void> _loadSession() async {
    _orgId = await secureStorage.orgId ?? 0;
  }

  void onQueryChanged(String value) {
    final query = value.trim();
    hasQuery.value = query.isNotEmpty;
    _debounce?.cancel();

    if (query.isEmpty) {
      results.clear();
      isLoading.value = false;
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    final token = ++_requestToken;
    isLoading.value = true;
    try {
      final assets = await assetRepository.getAssetsForLinkTag(
        assetName: query,
        orgId: _orgId,
      );
      if (token != _requestToken) return;
      results.assignAll(assets);
    } catch (_) {
      if (token != _requestToken) return;
      results.clear();
    } finally {
      if (token == _requestToken) isLoading.value = false;
    }
  }

  void selectAsset(AssetLinkTagModel asset) {
    Get.back(result: asset);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
