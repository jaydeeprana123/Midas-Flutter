import 'dart:convert';

SystemVersionModel systemVersionModelFromJson(String str) =>
    SystemVersionModel.fromJson(json.decode(str));

String systemVersionModelToJson(SystemVersionModel data) =>
    json.encode(data.toJson());

class SystemVersionModel {
  String version;
  String organizationLabel;

  SystemVersionModel({
    required this.version,
    required this.organizationLabel,
  });

  factory SystemVersionModel.fromJson(Map<String, dynamic> json) =>
      SystemVersionModel(
        version: (json["applicationVersion"] ??
                json["systemVersion"] ??
                json["version"] ??
                json["ApplicationVersion"] ??
                json["SystemVersion"] ??
                json["Version"] ??
                "")
            .toString(),
        organizationLabel: (json["organizationLabel"] ??
                json["orgLabel"] ??
                json["OrganizationLabel"] ??
                json["OrgLabel"] ??
                "")
            .toString(),
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "organizationLabel": organizationLabel,
      };
}
