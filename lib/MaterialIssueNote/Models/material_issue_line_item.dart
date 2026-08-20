import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/MaterialIssueNote/Models/material_indent_model.dart';

class MaterialIssueLineItem {
  MaterialIssueLineItem({
    required this.materialId,
    required this.materialName,
    required this.materialCode,
    required this.availableStock,
    required this.indentQty,
    this.uomId,
    this.uomName = '',
    this.indentUomName = '',
  }) {
    remainingQty.value = indentQty;
    finalStock.value = availableStock;
    issuedQtyController.addListener(recalculate);
  }

  factory MaterialIssueLineItem.fromDetail(MaterialIndentDetailModel detail) {
    return MaterialIssueLineItem(
      materialId: detail.materialId,
      materialName: detail.materialName,
      materialCode: detail.materialCode,
      availableStock: detail.availableStock,
      indentQty: detail.indentQty,
      uomId: detail.unitId,
      uomName: detail.uomName,
      indentUomName: detail.indentUomName,
    );
  }

  final int materialId;
  final String materialName;
  final String materialCode;
  final double availableStock;
  final double indentQty;
  final int? uomId;
  final String uomName;
  final String indentUomName;

  final issuedQtyController = TextEditingController();
  final descriptionController = TextEditingController();
  final remainingQty = 0.0.obs;
  final finalStock = 0.0.obs;
  final qtyError = ''.obs;

  double get issuedQty => double.tryParse(issuedQtyController.text.trim()) ?? 0;

  void recalculate() {
    final raw = issuedQtyController.text.trim();
    if (raw.isEmpty) {
      remainingQty.value = indentQty;
      finalStock.value = availableStock;
      qtyError.value = '';
      return;
    }

    final issued = double.tryParse(raw);
    if (issued == null) {
      remainingQty.value = indentQty;
      finalStock.value = availableStock;
      qtyError.value = 'Enter a valid issued quantity.';
      return;
    }

    if (issued < 0) {
      remainingQty.value = indentQty;
      finalStock.value = availableStock;
      qtyError.value = 'Issued quantity cannot be negative.';
      return;
    }

    remainingQty.value = indentQty - issued;
    finalStock.value = availableStock - issued;

    if (issued > availableStock && issued > indentQty) {
      qtyError.value =
          'Issued quantity cannot be greater than available stock or indent quantity.';
    } else if (issued > availableStock) {
      qtyError.value =
          'Issued quantity cannot be greater than available stock.';
    } else if (issued > indentQty) {
      qtyError.value =
          'Issued quantity cannot be greater than indent quantity.';
    } else {
      qtyError.value = '';
    }
  }

  bool validateForSubmit() {
    final raw = issuedQtyController.text.trim();
    if (raw.isEmpty) {
      qtyError.value = 'Issued quantity is required.';
      return false;
    }
    recalculate();
    return qtyError.value.isEmpty;
  }

  void dispose() {
    issuedQtyController.removeListener(recalculate);
    issuedQtyController.dispose();
    descriptionController.dispose();
  }
}
