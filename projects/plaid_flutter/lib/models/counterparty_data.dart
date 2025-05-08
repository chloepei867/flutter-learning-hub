class CounterpartyData {
  final String name;
  final String type;
  final String? logoUrl;
  final String? website;
  final String? entityId;
  final String? confidenceLevel;

  CounterpartyData({
    required this.name,
    required this.type,
    this.logoUrl,
    this.website,
    this.entityId,
    this.confidenceLevel,
  });

  factory CounterpartyData.fromJson(Map<String, dynamic> json) {
    return CounterpartyData(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      logoUrl: json['logo_url'],
      website: json['website'],
      entityId: json['entity_id'],
      confidenceLevel: json['confidence_level'],
    );
  }
}
