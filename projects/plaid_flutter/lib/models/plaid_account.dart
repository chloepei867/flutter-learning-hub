import 'package:flutter/material.dart';

class PlaidAccount {
  final String id;
  final String name;
  final String? officialName;
  final String type;
  final String subtype;
  final double? balanceAvailable;
  final double balanceCurrent;
  final String? balanceLimit;
  final String currency;
  final String mask;
  final String? holderCategory;

  PlaidAccount({
    required this.id,
    required this.name,
    this.officialName,
    required this.type,
    required this.subtype,
    this.balanceAvailable,
    required this.balanceCurrent,
    this.balanceLimit,
    required this.currency,
    required this.mask,
    this.holderCategory,
  });

  factory PlaidAccount.fromJson(Map<String, dynamic> json) {
    return PlaidAccount(
      id: json['account_id'],
      name: json['name'],
      officialName: json['official_name'],
      type: json['type'],
      subtype: json['subtype'],
      balanceAvailable: json['balances']['available']?.toDouble(),
      balanceCurrent: json['balances']['current']?.toDouble() ?? 0.0,
      balanceLimit: json['balances']['limit']?.toString(),
      currency: json['balances']['iso_currency_code'] ??
          json['balances']['unofficial_currency_code'] ?? 'USD',
      mask: json['mask'] ?? '****',
      holderCategory: json['holder_category'],
    );
  }

  String getAccountTypeDisplay() {
    // Capitalize first letter and replace underscores with spaces
    String displayType = type.substring(0, 1).toUpperCase() + type.substring(1);
    String displaySubtype = subtype.substring(0, 1).toUpperCase() + subtype.substring(1);
    return '$displayType - $displaySubtype';
  }

  String getFormattedBalance() {
    return '${balanceCurrent.toStringAsFixed(2)}';
  }

  String getAccountNumberDisplay() {
    return 'xxxx-xxxx-xxxx-$mask';
  }

  IconData getAccountTypeIcon() {
    switch (type.toLowerCase()) {
      case 'depository':
        return Icons.account_balance;
      case 'credit':
        return Icons.credit_card;
      case 'loan':
        return Icons.money;
      case 'investment':
        return Icons.trending_up;
      case 'brokerage':
        return Icons.show_chart;
      case 'other':
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color getAccountTypeColor() {
    switch (type.toLowerCase()) {
      case 'depository':
        return Colors.blue;
      case 'credit':
        return Colors.purple;
      case 'loan':
        return Colors.red;
      case 'investment':
        return Colors.green;
      case 'brokerage':
        return Colors.amber;
      case 'other':
      default:
        return Colors.grey;
    }
  }
}