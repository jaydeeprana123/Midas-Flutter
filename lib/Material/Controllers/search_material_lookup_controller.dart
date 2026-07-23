import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/Material/Services/material_sqlite_service.dart';
import 'package:midas/Material/Services/network_connectivity_service.dart';
import 'package:midas/Material/material_repository.dart';
import 'package:midas/app/constants/app_strings.dart';

class SearchMaterialLookupController extends GetxController {
  SearchMaterialLookupController({
    required this.materialRepository,
    required this.sqliteService,
    required this.connectivityService,
  });

  final MaterialRepository materialRepository;
  final MaterialSqliteService sqliteService;
  final NetworkConnectivityService connectivityService;

  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  final allMaterials = <MaterialTaggingDetailModel>[].obs;
  final filteredMaterials = <MaterialTaggingDetailModel>[].obs;
  final isLoading = false.obs;
  final hasQuery = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMaterials();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchFocusNode.canRequestFocus) {
        searchFocusNode.requestFocus();
      }
    });
  }

  Future<void> _loadMaterials() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final online = await connectivityService.refresh();
      if (online) {
        await _loadOnline();
      } else {
        await _loadOffline();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOnline() async {
    try {
      final result = await materialRepository.getMaterialTaggingDetails();
      if (!result.succeeded) {
        final cached = await sqliteService.getAllMaterialTagDetails();
        if (cached.isNotEmpty) {
          allMaterials.assignAll(cached);
          return;
        }
        errorMessage.value = result.message.isNotEmpty
            ? result.message
            : AppStrings.unableToFetchMaterialDetails;
        return;
      }

      await sqliteService.upsertMaterialTagDetails(result.items);
      allMaterials.assignAll(result.items);
    } catch (_) {
      final cached = await sqliteService.getAllMaterialTagDetails();
      if (cached.isNotEmpty) {
        allMaterials.assignAll(cached);
        return;
      }
      errorMessage.value = AppStrings.unableToFetchMaterialDetailsRetry;
    }
  }

  Future<void> _loadOffline() async {
    final cached = await sqliteService.getAllMaterialTagDetails();
    if (cached.isNotEmpty) {
      allMaterials.assignAll(cached);
      return;
    }
    errorMessage.value = AppStrings.noOfflineMaterialDetails;
  }

  void onQueryChanged(String value) {
    final query = value.trim();
    hasQuery.value = query.isNotEmpty;

    if (query.isEmpty) {
      filteredMaterials.clear();
      return;
    }

    final lower = query.toLowerCase();
    filteredMaterials.assignAll(
      allMaterials.where((item) {
        return item.materialName.toLowerCase().contains(lower) ||
            item.materialCode.toLowerCase().contains(lower) ||
            item.tagCode.toLowerCase().contains(lower);
      }),
    );
  }

  void selectMaterial(MaterialTaggingDetailModel material) {
    Get.back(result: material);
  }

  @override
  void onClose() {
    searchFocusNode.dispose();
    searchController.dispose();
    super.onClose();
  }
}
