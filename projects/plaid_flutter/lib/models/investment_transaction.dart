class InvestmentTransaction {
  final String investmentTransactionId;
  final String accountId;
  final String securityId;
  final String date;
  final String name;
  final double amount;
  final double price;
  final double quantity;
  final String type;
  final String subtype;
  final double fees;
  final String isoCurrencyCode;
  final String? cancelTransactionId;
  final String? unofficialCurrencyCode;

  InvestmentTransaction({
    required this.investmentTransactionId,
    required this.accountId,
    required this.securityId,
    required this.date,
    required this.name,
    required this.amount,
    required this.price,
    required this.quantity,
    required this.type,
    required this.subtype,
    required this.fees,
    required this.isoCurrencyCode,
    this.cancelTransactionId,
    this.unofficialCurrencyCode,
  });

  factory InvestmentTransaction.fromJson(Map<String, dynamic> json) {
    return InvestmentTransaction(
      investmentTransactionId: json['investment_transaction_id'],
      accountId: json['account_id'],
      securityId: json['security_id'],
      date: json['date'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      type: json['type'],
      subtype: json['subtype'],
      fees: (json['fees'] as num).toDouble(),
      isoCurrencyCode: json['iso_currency_code'],
      cancelTransactionId: json['cancel_transaction_id'],
      unofficialCurrencyCode: json['unofficial_currency_code'],
    );
  }
}
