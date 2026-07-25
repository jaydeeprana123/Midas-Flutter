class PendingMaterialLinkLocationModel {
  const PendingMaterialLinkLocationModel({
    required this.locationCode,
    required this.tagCodes,
    this.id,
    this.tagCode,
    this.createdAt,
    this.status = 'pending',
  });

  final int? id;
  final String locationCode;
  final List<String> tagCodes;
  final String? tagCode;
  final String? createdAt;
  final String status;

  Map<String, dynamic> toSqliteMap() => {
        'location_code': locationCode,
        'detail_ids_json': tagCodes.join(','),
        'tag_code': tagCode,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
        'status': status,
      };

  factory PendingMaterialLinkLocationModel.fromSqlite(
    Map<String, dynamic> row,
  ) {
    final codesRaw = (row['detail_ids_json'] ?? '').toString();
    final codes = codesRaw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return PendingMaterialLinkLocationModel(
      id: row['id'] as int?,
      locationCode: (row['location_code'] ?? '').toString(),
      tagCodes: codes,
      tagCode: (row['tag_code'] as String?)?.trim(),
      createdAt: row['created_at'] as String?,
      status: (row['status'] as String?) ?? 'pending',
    );
  }
}
