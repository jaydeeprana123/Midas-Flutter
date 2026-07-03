import 'dart:convert';

import 'package:midas/Shared/Models/app_permission_model.dart';

LoginResponseModel loginResponseModelFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) =>
    json.encode(data.toJson());

class LoginResponseModel {
  bool isSuccess;
  int status;
  String message;
  LoginData? data;

  LoginResponseModel({
    required this.isSuccess,
    required this.status,
    required this.message,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        isSuccess: json["isSuccess"] ?? json["IsSuccess"] ?? false,
        status: _toInt(json["status"] ?? json["Status"]) ?? 0,
        message: (json["message"] ?? json["Message"] ?? "").toString(),
        data: json["data"] == null
            ? null
            : LoginData.fromJson(Map<String, dynamic>.from(json["data"])),
      );

  Map<String, dynamic> toJson() => {
        "isSuccess": isSuccess,
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class LoginData {
  int? id;
  int? orgId;
  int? orgGroupId;
  String organizationName;
  String name;
  String token;
  List<AppPermission> applicationPermission;

  LoginData({
    this.id,
    this.orgId,
    this.orgGroupId,
    required this.organizationName,
    required this.name,
    required this.token,
    required this.applicationPermission,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        id: _toInt(json["id"] ?? json["Id"]),
        orgId: _toInt(json["orgID"] ?? json["orgId"] ?? json["OrgID"]),
        orgGroupId: _toInt(json["orgGroupId"] ?? json["OrgGroupId"]),
        organizationName:
            (json["organizationName"] ?? json["OrganizationName"] ?? "")
                .toString(),
        name: (json["name"] ?? json["Name"] ?? "").toString(),
        token: (json["token"] ?? json["Token"] ?? "").toString(),
        applicationPermission: json["applicationPermission"] is List
            ? List<AppPermission>.from(
                (json["applicationPermission"] as List)
                    .whereType<Map>()
                    .map((x) => AppPermission.fromJson(
                        Map<String, dynamic>.from(x))),
              )
            : <AppPermission>[],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "orgID": orgId,
        "orgGroupId": orgGroupId,
        "organizationName": organizationName,
        "name": name,
        "token": token,
        "applicationPermission":
            List<dynamic>.from(applicationPermission.map((x) => x.toJson())),
      };
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
