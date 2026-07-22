import 'dart:convert';

import 'package:midas/Material/Models/add_material_tagging_request.dart';

class PendingMaterialAssignTagModel {
  const PendingMaterialAssignTagModel({
    required this.request,
    this.id,
    this.createdAt,
    this.status = 'pending',
  });

  final int? id;
  final AddMaterialTaggingRequest request;
  final String? createdAt;
  final String status;

  String? get tagCode {
    if (request.materialTagingDetails.isEmpty) return null;
    return request.materialTagingDetails.first.tagCode;
  }

  Map<String, dynamic> toSqliteMap() => {
        'request_json': jsonEncode(request.toJson()),
        'tag_code': tagCode,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
        'status': status,
      };

  factory PendingMaterialAssignTagModel.fromSqlite(Map<String, dynamic> row) {
    final json = jsonDecode(row['request_json'] as String) as Map<String, dynamic>;
    return PendingMaterialAssignTagModel(
      id: row['id'] as int?,
      request: AddMaterialTaggingRequest.fromJson(json),
      createdAt: row['created_at'] as String?,
      status: (row['status'] as String?) ?? 'pending',
    );
  }
}
