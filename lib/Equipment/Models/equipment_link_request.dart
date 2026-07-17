class EquipmentLinkRequest {
  const EquipmentLinkRequest({
    required this.equipmentId,
    required this.equipmentCode,
    required this.tagCode,
    this.tagId = 0,
  });

  final int equipmentId;
  final int tagId;
  final String equipmentCode;
  final String tagCode;

  Map<String, dynamic> toJson() => {
        'equipmentId': equipmentId,
        'tagId': tagId,
        'equipmentCode': equipmentCode,
        'tagCode': tagCode,
      };
}
