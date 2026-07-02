class OrgInfo {
  const OrgInfo({required this.version, required this.organizationLabel});

  final String version;
  final String organizationLabel;

  factory OrgInfo.fromJson(Map<String, dynamic> json) {
    final version = (json['applicationVersion'] ??
            json['systemVersion'] ??
            json['version'] ??
            json['ApplicationVersion'] ??
            json['SystemVersion'] ??
            json['Version'] ??
            '')
        .toString();

    final label = (json['organizationLabel'] ??
            json['orgLabel'] ??
            json['OrganizationLabel'] ??
            json['OrgLabel'] ??
            '')
        .toString();

    return OrgInfo(version: version, organizationLabel: label);
  }
}
