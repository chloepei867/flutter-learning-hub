class PersonalFinanceCategory {
  final String primary;
  final String detailed;
  final String confidenceLevel;

  PersonalFinanceCategory({
    required this.primary,
    required this.detailed,
    required this.confidenceLevel,
  });

  factory PersonalFinanceCategory.fromJson(Map<String, dynamic> json) {
    return PersonalFinanceCategory(
      primary: json['primary'] ?? '',
      detailed: json['detailed'] ?? '',
      confidenceLevel: json['confidence_level'] ?? '',
    );
  }
}