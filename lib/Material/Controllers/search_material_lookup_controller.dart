import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/app/constants/app_strings.dart';

class SearchMaterialLookupController extends GetxController {
  SearchMaterialLookupController({required this.materialRepository});

  final MaterialRepository materialRepository;

  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  final results = <MaterialTaggingDetailModel>[].obs;
  final isLoading = false.obs;
  final hasQuery = false.obs;
  final errorMessage = ''.obs;

  Timer? _debounce;
  int _requestToken = 0;

  static const _minQueryLength = 1;

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
    errorMessage.value = '';
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
    errorMessage.value = '';
    try {
      final materials =
          await materialRepository.searchMaterialForMobileApp(query);
      if (token != _requestToken) return;
      results.assignAll(materials);
    } on DioException catch (e) {
      if (token != _requestToken) return;
      results.clear();
      if (_isNotFound(e)) return;
      final data = e.response?.data;
      errorMessage.value = data is Map && data['message'] != null
          ? data['message'].toString()
          : AppStrings.unableToFetchMaterialDetailsRetry;
    } catch (_) {
      if (token != _requestToken) return;
      results.clear();
      errorMessage.value = AppStrings.unableToFetchMaterialDetailsRetry;
    } finally {
      if (token == _requestToken) isLoading.value = false;
    }
  }

  bool _isNotFound(DioException e) {
    final status = e.response?.statusCode;
    if (status == 404) return true;
    final data = e.response?.data;
    if (data is Map) {
      final apiStatus = data['status'];
      if (apiStatus == 404) return true;
      final message = (data['message'] ?? '').toString().toLowerCase();
      if (message.contains('not found')) return true;
    }
    return false;
  }

  void selectMaterial(MaterialTaggingDetailModel material) {
    Get.back(result: material);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchFocusNode.dispose();
    searchController.dispose();
    super.onClose();
  }
}
