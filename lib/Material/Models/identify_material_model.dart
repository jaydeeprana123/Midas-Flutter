class IdentifyMaterialModel {
  const IdentifyMaterialModel({
    required this.materialName,
    required this.materialCode,
    required this.tagCode,
    required this.rfid,
    required this.locationCode,
    required this.location,
  });

  final String materialName;
  final String materialCode;
  final String tagCode;
  final String rfid;
  final String locationCode;
  final String location;

  factory IdentifyMaterialModel.fromJson(Map<String, dynamic> json) {
    return IdentifyMaterialModel(
      materialName: _toStr(json['name'] ?? json['Name']),
      materialCode: _toStr(json['code'] ?? json['Code']),
      tagCode: _toStr(json['tagCode'] ?? json['TagCode']),
      rfid: _toStr(json['rfid'] ?? json['Rfid'] ?? json['RFID']),
      locationCode: _toStr(json['locationCode'] ?? json['LocationCode']),
      location: _toStr(json['location'] ?? json['Location']),
    );
  }

  static String _toStr(dynamic value) => (value ?? '').toString().trim();
}

class IdentifyMaterialResult {
  const IdentifyMaterialResult({
    required this.succeeded,
    required this.message,
    this.material,
  });

  final bool succeeded;
  final String message;
  final IdentifyMaterialModel? material;

  factory IdentifyMaterialResult.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['isSuccess'] == true || json['IsSuccess'] == true;
    final status = json['status'] ?? json['Status'];
    final succeeded = isSuccess || status == 200;

    final data = json['data'] ?? json['Data'];
    IdentifyMaterialModel? material;
    if (data is Map) {
      material = IdentifyMaterialModel.fromJson(Map<String, dynamic>.from(data));
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      material = IdentifyMaterialModel.fromJson(
        Map<String, dynamic>.from(data.first as Map),
      );
    }

    return IdentifyMaterialResult(
      succeeded: succeeded,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      material: material,
    );
  }
}
