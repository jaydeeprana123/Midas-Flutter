import 'dart:convert';

LoginRequestModel loginRequestModelFromJson(String str) =>
    LoginRequestModel.fromJson(json.decode(str));

String loginRequestModelToJson(LoginRequestModel data) =>
    json.encode(data.toJson());

class LoginRequestModel {
  String username;
  String password;
  String macAddress;

  LoginRequestModel({
    required this.username,
    required this.password,
    required this.macAddress,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      LoginRequestModel(
        username: json["Username"] ?? "",
        password: json["Password"] ?? "",
        macAddress: json["MacAddress"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "Username": username,
        "Password": password,
        "MacAddress": macAddress,
      };
}
