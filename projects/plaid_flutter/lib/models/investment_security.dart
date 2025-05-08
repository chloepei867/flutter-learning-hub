class InvestmentSecurity {
  final String securityId;
  final String name;
  final String? tickerSymbol;
  final String type;
  final String isoCurrencyCode;
  final double? closePrice;
  final String? closePriceAsOf;
  final String? isin;
  final String? cusip;
  final String? sedol;
  final String? marketIdentifierCode;

  InvestmentSecurity({
    required this.securityId,
    required this.name,
    this.tickerSymbol,
    required this.type,
    required this.isoCurrencyCode,
    this.closePrice,
    this.closePriceAsOf,
    this.isin,
    this.cusip,
    this.sedol,
    this.marketIdentifierCode,
  });

  factory InvestmentSecurity.fromJson(Map<String, dynamic> json) {
    return InvestmentSecurity(
      securityId: json['security_id'],
      name: json['name'],
      tickerSymbol: json['ticker_symbol'],
      type: json['type'],
      isoCurrencyCode: json['iso_currency_code'],
      closePrice: (json['close_price'] as num?)?.toDouble(),
      closePriceAsOf: json['close_price_as_of'],
      isin: json['isin'],
      cusip: json['cusip'],
      sedol: json['sedol'],
      marketIdentifierCode: json['market_identifier_code'],
    );
  }
}
