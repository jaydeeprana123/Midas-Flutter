import 'dart:convert';

AppPermission appPermissionFromJson(String str) =>
    AppPermission.fromJson(json.decode(str));

String appPermissionToJson(AppPermission data) => json.encode(data.toJson());

class AppPermission {
  const AppPermission({
    required this.label,
    this.module,
    this.isDeleted = false,
  });

  final String label;
  final int? module;
  final bool isDeleted;

  bool get isActive => label.isNotEmpty && !isDeleted;

  factory AppPermission.fromJson(Map<String, dynamic> json) {
    return AppPermission(
      label: (json['label'] ?? json['Label'] ?? '').toString().trim(),
      module: _readInt(json['module'] ?? json['Module']),
      isDeleted: json['isDeleted'] == true || json['IsDeleted'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'module': module,
        'isDeleted': isDeleted,
      };

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
