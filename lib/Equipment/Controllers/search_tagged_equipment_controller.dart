import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/Equipment/Models/tagged_equipment_model.dart';
import 'package:midas/Equipment/equipment_repository.dart';
import 'package:midas/app/constants/app_strings.dart';

class SearchTaggedEquipmentController extends GetxController {
  SearchTaggedEquipmentController({required this.equipmentRepository});

  final EquipmentRepository equipmentRepository;

  final searchController = TextEditingController();

  final allEquipment = <TaggedEquipmentModel>[].obs;
  final filteredEquipment = <TaggedEquipmentModel>[].obs;
  final isLoading = false.obs;
  final hasQuery = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await equipmentRepository.getEquipmentTagMappings();
      allEquipment.assignAll(result);
      _applyFilter(searchController.text);
    } catch (_) {
      allEquipment.clear();
      filteredEquipment.clear();
      errorMessage.value = AppStrings.unableToFetchEquipmentList;
    } finally {
      isLoading.value = false;
    }
  }

  void onQueryChanged(String value) {
    _applyFilter(value);
  }

  void _applyFilter(String value) {
    final query = value.trim();
    hasQuery.value = query.isNotEmpty;

    if (query.isEmpty) {
      filteredEquipment.clear();
      return;
    }

    final lower = query.toLowerCase();
    filteredEquipment.assignAll(
      allEquipment.where((item) {
        return item.equipmentTypeName.toLowerCase().contains(lower) ||
            item.equipmentCode.toLowerCase().contains(lower) ||
            (item.rfidTagCode?.toLowerCase().contains(lower) ?? false);
      }),
    );
  }

  void selectEquipment(TaggedEquipmentModel equipment) {
    Get.back(result: equipment);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
