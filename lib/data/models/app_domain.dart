class AppDomain {
  const AppDomain({required this.url});

  final String url;

  factory AppDomain.fromDynamic(dynamic value) {
    if (value is String) return AppDomain(url: value);
    if (value is Map<String, dynamic>) {
      final possibleOptions = [
        value['domainName'],
        value['domain'],
        value['baseUrl'],
        value['url'],
        value['DomainName'],
        value['Domain'],
        value['BaseUrl'],
        value['Url'],
      ].whereType<String>();
      for (final option in possibleOptions) {
        if (option.trim().isNotEmpty) return AppDomain(url: option);
      }
    }
    return const AppDomain(url: '');
  }
}
