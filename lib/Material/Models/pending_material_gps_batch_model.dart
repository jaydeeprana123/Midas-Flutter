import 'dart:convert';

import 'package:midas/SearchAsset/Models/gps_data_model.dart';

class PendingMaterialGpsBatchModel {
  const PendingMaterialGpsBatchModel({
    required this.readings,
    this.id,
    this.materialTagCode,
    this.createdAt,
    this.status = 'pending',
  });

  final int? id;
  final List<GpsDataModel> readings;
  final String? materialTagCode;
  final String? createdAt;
  final String status;

  Map<String, dynamic> toSqliteMap() => {
        'readings_json': jsonEncode(
          readings.map((item) => item.toJson()).toList(),
        ),
        'material_tag_code': materialTagCode,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
        'status': status,
      };

  factory PendingMaterialGpsBatchModel.fromSqlite(Map<String, dynamic> row) {
    final decoded = jsonDecode(row['readings_json'] as String);
    final readings = <GpsDataModel>[];
    if (decoded is List) {
      for (final item in decoded.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        readings.add(
          GpsDataModel(
            rfidNumber: (map['rfidnumber'] ?? map['rfidNumber'] ?? '').toString(),
            latitude: _toDouble(map['latitude']) ?? 0,
            longitude: _toDouble(map['longitude']) ?? 0,
            timestamp: (map['timestamp'] ?? '').toString(),
            isHandHeld: map['isHandHeld'] != false,
            frequencyPoint: _toDouble(map['frequencyPoint']) ?? 0,
          ),
        );
      }
    }

    return PendingMaterialGpsBatchModel(
      id: row['id'] as int?,
      readings: readings,
      materialTagCode: (row['material_tag_code'] as String?)?.trim(),
      createdAt: row['created_at'] as String?,
      status: (row['status'] as String?) ?? 'pending',
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
