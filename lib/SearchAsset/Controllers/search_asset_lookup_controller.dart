import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/SearchAsset/Models/search_asset_item_model.dart';
import 'package:midas/SearchAsset/search_asset_repository.dart';

class SearchAssetLookupController extends GetxController {
  SearchAssetLookupController({required this.searchAssetRepository});

  final SearchAssetRepository searchAssetRepository;

  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  final results = <SearchAssetItemModel>[].obs;
  final isLoading = false.obs;
  final hasQuery = false.obs;

  Timer? _debounce;
  int _requestToken = 0;

  static const _minQueryLength = 2;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchFocusNode.canRequestFocus) {
        searchFocusNode.requestFocus();
      }
    });
  }

  void onQueryChanged(String value) {
    final query = value.trim();
    hasQuery.value = query.length >= _minQueryLength;
    _debounce?.cancel();

    if (query.length < _minQueryLength) {
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
      final assets =
          await searchAssetRepository.searchAssetsForMobileApp(query);
      if (token != _requestToken) return;
      results.assignAll(assets);
    } catch (_) {
      if (token != _requestToken) return;
      results.clear();
    } finally {
      if (token == _requestToken) isLoading.value = false;
    }
  }

  void selectAsset(SearchAssetItemModel asset) {
    Get.back(result: asset);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchFocusNode.dispose();
    searchController.dispose();
    super.onClose();
  }
}
