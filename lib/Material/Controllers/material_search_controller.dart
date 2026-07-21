import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Models/material_by_inward_type_model.dart';

class MaterialSearchController extends GetxController {
  final searchController = TextEditingController();

  final allMaterials = <MaterialByInwardTypeModel>[].obs;
  final filteredMaterials = <MaterialByInwardTypeModel>[].obs;
  final hasQuery = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is List<MaterialByInwardTypeModel>) {
      allMaterials.assignAll(args);
    } else if (args is List) {
      allMaterials.assignAll(
        args.whereType<MaterialByInwardTypeModel>(),
      );
    }
  }

  void onQueryChanged(String value) {
    _applyFilter(value);
  }

  void _applyFilter(String value) {
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
            item.code.toLowerCase().contains(lower);
      }),
    );
  }

  void selectMaterial(MaterialByInwardTypeModel material) {
    Get.back(result: material);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
