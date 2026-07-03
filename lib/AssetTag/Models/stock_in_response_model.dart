import 'dart:convert';

StockInResponseModel stockInResponseModelFromJson(String str) =>
    StockInResponseModel.fromJson(json.decode(str));

String stockInResponseModelToJson(StockInResponseModel data) =>
    json.encode(data.toJson());

class StockInResponseModel {
  bool isSuccess;
  int status;
  String message;
  dynamic data;

  StockInResponseModel({
    required this.isSuccess,
    required this.status,
    required this.message,
    this.data,
  });

  factory StockInResponseModel.fromJson(Map<String, dynamic> json) =>
      StockInResponseModel(
        isSuccess: json["isSuccess"] ?? json["IsSuccess"] ?? false,
        status: _toInt(json["status"] ?? json["Status"]) ?? 0,
        message: (json["message"] ?? json["Message"] ?? "").toString(),
        data: json["data"] ?? json["Data"],
      );

  Map<String, dynamic> toJson() => {
        "isSuccess": isSuccess,
        "status": status,
        "message": message,
        "data": data,
      };

  bool get succeeded => isSuccess || status == 200;

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
