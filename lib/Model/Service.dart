class ServiceModel {
  final String id;
  final String name;
  final String? logo;
  final bool requiresActiveAccount;
  final List<Map<String, dynamic>> providers;

  ServiceModel({
    required this.id,
    required this.name,
    required this.requiresActiveAccount,
    required this.providers,
    this.logo,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'].toString(),
      name: json['name'],
      logo: json['logo'],
      requiresActiveAccount:
          json['requires_active_account'] == true ||
          json['requires_active_account'] == 1,
      providers: List<Map<String, dynamic>>.from(json['providers'] ?? []),
    );
  }
}
