class PendingMaterialUnassignModel {
  const PendingMaterialUnassignModel({
    required this.detailIds,
    this.id,
    this.tagCode,
    this.createdAt,
    this.status = 'pending',
  });

  final int? id;
  final List<int> detailIds;
  final String? tagCode;
  final String? createdAt;
  final String status;

  Map<String, dynamic> toSqliteMap() => {
        'detail_ids_json': detailIds.join(','),
        'tag_code': tagCode,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
        'status': status,
      };

  factory PendingMaterialUnassignModel.fromSqlite(Map<String, dynamic> row) {
    final idsRaw = (row['detail_ids_json'] ?? '').toString();
    final ids = idsRaw
        .split(',')
        .map((part) => int.tryParse(part.trim()))
        .whereType<int>()
        .toList();

    return PendingMaterialUnassignModel(
      id: row['id'] as int?,
      detailIds: ids,
      tagCode: (row['tag_code'] as String?)?.trim(),
      createdAt: row['created_at'] as String?,
      status: (row['status'] as String?) ?? 'pending',
    );
  }
}
