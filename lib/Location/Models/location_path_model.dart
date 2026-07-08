class LocationPathModel {
  const LocationPathModel({
    this.sectionName = '',
    this.areaName = '',
    this.zoneName = '',
    this.aisleName = '',
    this.rackName = '',
  });

  final String sectionName;
  final String areaName;
  final String zoneName;
  final String aisleName;
  final String rackName;

  factory LocationPathModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LocationPathModel();
    return LocationPathModel(
      sectionName: _str(json['sectionName'] ?? json['SectionName']),
      areaName: _str(json['areaName'] ?? json['AreaName']),
      zoneName: _str(json['zoneName'] ?? json['ZoneName']),
      aisleName: _str(json['aisleName'] ?? json['AisleName']),
      rackName: _str(json['rackName'] ?? json['RackName']),
    );
  }

  String get displayPath {
    return [
      sectionName,
      areaName,
      zoneName,
      aisleName,
      rackName,
    ].where((part) => part.isNotEmpty).join(' => ');
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();
}
