import 'dart:convert';

List<DomainModel> domainModelListFromJson(String str) =>
    List<DomainModel>.from(
        json.decode(str).map((x) => DomainModel.fromDynamic(x)));

String domainModelListToJson(List<DomainModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DomainModel {
  String url;

  DomainModel({required this.url});

  factory DomainModel.fromJson(Map<String, dynamic> json) => DomainModel(
        url: (json["domainName"] ??
                json["domain"] ??
                json["baseUrl"] ??
                json["url"] ??
                json["DomainName"] ??
                json["Domain"] ??
                json["BaseUrl"] ??
                json["Url"] ??
                "")
            .toString()
            .trim(),
      );

  /// Domains may arrive either as raw strings or as objects; handle both.
  factory DomainModel.fromDynamic(dynamic value) {
    if (value is String) return DomainModel(url: value.trim());
    if (value is Map) {
      return DomainModel.fromJson(Map<String, dynamic>.from(value));
    }
    return DomainModel(url: '');
  }

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}
