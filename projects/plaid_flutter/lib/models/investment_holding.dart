class InvestmentHolding {
  final String accountId;
  final double? costBasis;
  final double institutionPrice;
  final String? institutionPriceAsOf;
  final double institutionValue;
  final String isoCurrencyCode;
  final double quantity;
  final String securityId;
  final String? unofficialCurrencyCode;

  InvestmentHolding({
    required this.accountId,
    this.costBasis,
    required this.institutionPrice,
    this.institutionPriceAsOf,
    required this.institutionValue,
    required this.isoCurrencyCode,
    required this.quantity,
    required this.securityId,
    this.unofficialCurrencyCode,
  });

  factory InvestmentHolding.fromJson(Map<String, dynamic> json) {
    return InvestmentHolding(
      accountId: json['account_id'],
      costBasis: (json['cost_basis'] as num?)?.toDouble(),
      institutionPrice: (json['institution_price'] as num).toDouble(),
      institutionPriceAsOf: json['institution_price_as_of'],
      institutionValue: (json['institution_value'] as num).toDouble(),
      isoCurrencyCode: json['iso_currency_code'],
      quantity: (json['quantity'] as num).toDouble(),
      securityId: json['security_id'],
      unofficialCurrencyCode: json['unofficial_currency_code'],
    );
  }
}
