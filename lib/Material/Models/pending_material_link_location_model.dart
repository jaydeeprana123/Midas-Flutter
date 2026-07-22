class PendingMaterialLinkLocationModel {
  const PendingMaterialLinkLocationModel({
    required this.locationCode,
    required this.detailIds,
    this.id,
    this.tagCode,
    this.createdAt,
    this.status = 'pending',
  });

  final int? id;
  final String locationCode;
  final List<int> detailIds;
  final String? tagCode;
  final String? createdAt;
  final String status;

  Map<String, dynamic> toSqliteMap() => {
        'location_code': locationCode,
        'detail_ids_json': detailIds.join(','),
        'tag_code': tagCode,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
        'status': status,
      };

  factory PendingMaterialLinkLocationModel.fromSqlite(
    Map<String, dynamic> row,
  ) {
    final idsRaw = (row['detail_ids_json'] ?? '').toString();
    final ids = idsRaw
        .split(',')
        .map((part) => int.tryParse(part.trim()))
        .whereType<int>()
        .toList();

    return PendingMaterialLinkLocationModel(
      id: row['id'] as int?,
      locationCode: (row['location_code'] ?? '').toString(),
      detailIds: ids,
      tagCode: (row['tag_code'] as String?)?.trim(),
      createdAt: row['created_at'] as String?,
      status: (row['status'] as String?) ?? 'pending',
    );
  }
}
