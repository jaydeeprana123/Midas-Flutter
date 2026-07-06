class ChangeLocationRemarkModel {
  const ChangeLocationRemarkModel({
    required this.id,
    required this.name,
    this.description = '',
  });

  final int id;
  final String name;
  final String description;

  factory ChangeLocationRemarkModel.fromJson(Map<String, dynamic> json) =>
      ChangeLocationRemarkModel(
        id: _toInt(json['id'] ?? json['Id']) ?? 0,
        name: _str(json['name'] ?? json['Name']),
        description: _str(json['description'] ?? json['Description']),
      );

  static List<ChangeLocationRemarkModel> listFromResponse(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => ChangeLocationRemarkModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    }
    if (response is Map) {
      final data = response['data'] ?? response['Data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => ChangeLocationRemarkModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      }
    }
    return const [];
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
