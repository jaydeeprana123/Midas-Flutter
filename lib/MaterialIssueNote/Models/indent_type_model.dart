class IndentTypeModel {
  const IndentTypeModel({
    required this.id,
    required this.name,
    this.description = '',
  });

  final int id;
  final String name;
  final String description;

  String get displayLabel => name.trim().isEmpty ? 'Type $id' : name.trim();

  factory IndentTypeModel.fromJson(Map<String, dynamic> json) =>
      IndentTypeModel(
        id: _toInt(json['id'] ?? json['Id']) ?? 0,
        name: _str(json['name'] ?? json['Name']),
        description: _str(json['description'] ?? json['Description']),
      );

  static List<IndentTypeModel> listFromResponse(dynamic response) {
    return _extractList(response)
        .whereType<Map>()
        .map(
          (item) => IndentTypeModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.id > 0)
        .toList();
  }

  static List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      final data = response['data'] ?? response['Data'];
      if (data is List) return data;
    }
    return const [];
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is IndentTypeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
