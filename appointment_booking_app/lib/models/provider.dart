class Provider {
  final int providerId;
  final String serviceName;
  final String description;
  final String name;
  final String email;

  Provider({
    required this.providerId,
    required this.serviceName,
    required this.description,
    required this.name,
    required this.email,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      providerId: int.parse(json['provider_id'].toString()),
      serviceName: json['service_name'],
      description: json['description'] ?? '',
      name: json['name'],
      email: json['email'],
    );
  }
}