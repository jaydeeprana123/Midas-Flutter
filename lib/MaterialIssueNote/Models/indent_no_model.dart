class IndentNoModel {
  const IndentNoModel({
    required this.id,
    required this.indentNo,
  });

  final int id;
  final String indentNo;

  String get displayLabel =>
      indentNo.trim().isEmpty ? 'Indent $id' : indentNo.trim();

  factory IndentNoModel.fromJson(Map<String, dynamic> json) => IndentNoModel(
        id: _toInt(json['id'] ?? json['Id'] ?? json['indentId'] ?? json['IndentId']) ??
            0,
        indentNo: _str(
          json['indentNo'] ??
              json['IndentNo'] ??
              json['indentNumber'] ??
              json['IndentNumber'],
        ),
      );

  static List<IndentNoModel> listFromResponse(dynamic response) {
    return _extractList(response)
        .whereType<Map>()
        .map((item) => IndentNoModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id > 0 || item.indentNo.isNotEmpty)
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
      identical(this, other) || other is IndentNoModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
