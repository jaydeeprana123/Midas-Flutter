import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Material/Models/material_by_inward_type_model.dart';

class MaterialMultiSelectSearchController extends GetxController {
  final searchController = TextEditingController();

  final allMaterials = <MaterialByInwardTypeModel>[].obs;
  final filteredMaterials = <MaterialByInwardTypeModel>[].obs;
  final selectedKeys = <String>{}.obs;
  final hasQuery = false.obs;

  bool get canSubmit => selectedKeys.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    List<MaterialByInwardTypeModel> materials = const [];
    List<MaterialByInwardTypeModel> initiallySelected = const [];

    if (args is Map) {
      final list = args['materials'];
      final selected = args['selected'];
      if (list is List<MaterialByInwardTypeModel>) {
        materials = list;
      } else if (list is List) {
        materials = list.whereType<MaterialByInwardTypeModel>().toList();
      }
      if (selected is List<MaterialByInwardTypeModel>) {
        initiallySelected = selected;
      } else if (selected is List) {
        initiallySelected =
            selected.whereType<MaterialByInwardTypeModel>().toList();
      }
    } else if (args is List<MaterialByInwardTypeModel>) {
      materials = args;
    } else if (args is List) {
      materials = args.whereType<MaterialByInwardTypeModel>().toList();
    }

    allMaterials.assignAll(materials);
    selectedKeys
      ..clear()
      ..addAll(initiallySelected.map((item) => item.selectionKey));
    filteredMaterials.assignAll(materials);
  }

  void onQueryChanged(String value) {
    final query = value.trim();
    hasQuery.value = query.isNotEmpty;

    if (query.isEmpty) {
      filteredMaterials.assignAll(allMaterials);
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

  void toggleSelection(MaterialByInwardTypeModel material) {
    final key = material.selectionKey;
    if (selectedKeys.contains(key)) {
      selectedKeys.remove(key);
    } else {
      selectedKeys.add(key);
    }
    selectedKeys.refresh();
  }

  bool isSelected(MaterialByInwardTypeModel material) {
    return selectedKeys.contains(material.selectionKey);
  }

  void submit() {
    if (!canSubmit) return;
    final selected = allMaterials
        .where((item) => selectedKeys.contains(item.selectionKey))
        .toList();
    Get.back(result: selected);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
