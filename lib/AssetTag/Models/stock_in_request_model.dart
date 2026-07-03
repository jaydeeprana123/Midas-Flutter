import 'dart:convert';

StockInRequestModel stockInRequestModelFromJson(String str) =>
    StockInRequestModel.fromJson(json.decode(str));

String stockInRequestModelToJson(StockInRequestModel data) =>
    json.encode(data.toJson());

class StockInRequestModel {
  int orgId;
  int assetId;
  int createdById;
  bool isDeleted;
  List<StockInDetailModel> assetStockInDetails;

  StockInRequestModel({
    required this.orgId,
    required this.assetId,
    required this.createdById,
    this.isDeleted = false,
    required this.assetStockInDetails,
  });

  factory StockInRequestModel.fromJson(Map<String, dynamic> json) =>
      StockInRequestModel(
        orgId: json["orgId"] ?? 0,
        assetId: json["assetId"] ?? 0,
        createdById: json["createdById"] ?? 0,
        isDeleted: json["isDeleted"] ?? false,
        assetStockInDetails: json["assetStockInDetails"] is List
            ? List<StockInDetailModel>.from(
                (json["assetStockInDetails"] as List)
                    .whereType<Map>()
                    .map((x) => StockInDetailModel.fromJson(
                        Map<String, dynamic>.from(x))),
              )
            : <StockInDetailModel>[],
      );

  Map<String, dynamic> toJson() => {
        "orgId": orgId,
        "assetId": assetId,
        "createdById": createdById,
        "isDeleted": isDeleted,
        "assetStockInDetails":
            List<dynamic>.from(assetStockInDetails.map((x) => x.toJson())),
      };
}

class StockInDetailModel {
  String serialNo;
  String tagCode;

  StockInDetailModel({
    required this.serialNo,
    required this.tagCode,
  });

  factory StockInDetailModel.fromJson(Map<String, dynamic> json) =>
      StockInDetailModel(
        serialNo: (json["serialNo"] ?? "").toString(),
        tagCode: (json["tagCode"] ?? "").toString(),
      );

  Map<String, dynamic> toJson() => {
        "serialNo": serialNo,
        "tagCode": tagCode,
      };
}
