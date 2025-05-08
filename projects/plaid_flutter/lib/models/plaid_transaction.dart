import 'package:flutter/material.dart';
import 'package:personal_finance_app/models/location_data.dart';
import 'package:personal_finance_app/models/personal_finance_category.dart';
import 'package:personal_finance_app/models/counterparty_data.dart';

class PlaidTransaction {
  final String id;
  final String accountId;
  final String name;
  final String? merchantName;
  final String? logoUrl;
  final String? website;
  final double amount;
  final String date;
  final String? datetime;
  final String? authorizedDate;
  final List<String> categories;
  final String? categoryId;
  final String? paymentChannel;
  final bool pending;
  final String? pendingTransactionId;
  final String? transactionType;
  final String? paymentMethod;
  final String? accountOwner;
  final String currencyCode;
  final LocationData? location;
  final PersonalFinanceCategory? personalFinanceCategory;
  final String? personalFinanceCategoryIconUrl;
  final List<CounterpartyData>? counterparties;

  //constructor
  PlaidTransaction({
    required this.id,
    required this.accountId,
    required this.name,
    this.merchantName,
    this.logoUrl,
    this.website,
    required this.amount,
    required this.date,
    this.datetime,
    this.authorizedDate,
    required this.categories,
    this.categoryId,
    this.paymentChannel,
    required this.pending,
    this.pendingTransactionId,
    this.transactionType,
    this.paymentMethod,
    this.accountOwner,
    required this.currencyCode,
    this.location,
    this.personalFinanceCategory,
    this.personalFinanceCategoryIconUrl,
    this.counterparties,
  });

  //create instance from json data
  factory PlaidTransaction.fromJson(Map<String, dynamic> json) {
    List<String> categoryList = [];
    if (json['category'] != null) {
      categoryList = List<String>.from(json['category']);
    }

    // Parse location data if available
    LocationData? locationData;
    if (json['location'] != null) {
      locationData = LocationData.fromJson(json['location']);
    }

    // Parse personal finance category if available
    PersonalFinanceCategory? pfCategory;
    if (json['personal_finance_category'] != null) {
      pfCategory = PersonalFinanceCategory.fromJson(json['personal_finance_category']);
    }

    // Parse counterparties if available
    List<CounterpartyData>? counterpartiesList;
    if (json['counterparties'] != null) {
      counterpartiesList = (json['counterparties'] as List)
          .map((cp) => CounterpartyData.fromJson(cp))
          .toList();
    }

    return PlaidTransaction(
      id: json['transaction_id'],
      accountId: json['account_id'],
      name: json['name'],
      merchantName: json['merchant_name'],
      logoUrl: json['logo_url'],
      website: json['website'],
      amount: json['amount']?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
      datetime: json['datetime'],
      authorizedDate: json['authorized_date'],
      categories: categoryList,
      categoryId: json['category_id'],
      paymentChannel: json['payment_channel'],
      pending: json['pending'] ?? false,
      pendingTransactionId: json['pending_transaction_id'],
      transactionType: json['transaction_type'],
      paymentMethod: json['payment_meta'] != null ? json['payment_meta']['payment_method'] : null,
      accountOwner: json['account_owner'],
      currencyCode: json['iso_currency_code'] ?? 'USD',
      location: locationData,
      personalFinanceCategory: pfCategory,
      personalFinanceCategoryIconUrl: json['personal_finance_category_icon_url'],
      counterparties: counterpartiesList,
    );
  }

  String formatLocation() {
    if (location == null) return 'Unknown location';

    List<String> parts = [];
    if (location!.address != null && location!.address!.isNotEmpty) {
      parts.add(location!.address!);
    }

    if (location!.city != null && location!.city!.isNotEmpty) {
      parts.add(location!.city!);
    }

    if (location!.region != null && location!.region!.isNotEmpty) {
      parts.add(location!.region!);
    }

    if (location!.postalCode != null && location!.postalCode!.isNotEmpty) {
      parts.add(location!.postalCode!);
    }

    if (location!.country != null && location!.country!.isNotEmpty) {
      parts.add(location!.country!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Unknown location';
  }

  // Get primary category (first in the list)
  String getPrimaryCategory() {
    return categories.isNotEmpty ? categories[0] : 'Uncategorized';
  }

  // Format amount for display
  String getFormattedAmount() {
    return amount.abs().toStringAsFixed(2);
  }

  // Determine if transaction is income or expense
  bool isIncome() {
    return amount < 0; // In Plaid, negative amounts are money coming in
  }

  // Get icon for transaction based on category
  IconData getCategoryIcon() {
    if (categories.isEmpty) return Icons.category;

    String primaryCategory = categories[0].toLowerCase();

    if (primaryCategory.contains('food') ||
        primaryCategory.contains('restaurant') ||
        primaryCategory.contains('coffee')) {
      return Icons.restaurant;
    } else if (primaryCategory.contains('travel') ||
        primaryCategory.contains('hotel') ||
        primaryCategory.contains('airline')) {
      return Icons.flight;
    } else if (primaryCategory.contains('transport') ||
        primaryCategory.contains('taxi') ||
        primaryCategory.contains('uber')) {
      return Icons.directions_car;
    } else if (primaryCategory.contains('shopping') ||
        primaryCategory.contains('merchandise')) {
      return Icons.shopping_bag;
    } else if (primaryCategory.contains('medical') ||
        primaryCategory.contains('health') ||
        primaryCategory.contains('doctor')) {
      return Icons.medical_services;
    } else if (primaryCategory.contains('entertainment') ||
        primaryCategory.contains('recreation')) {
      return Icons.movie;
    } else if (primaryCategory.contains('payment') ||
        primaryCategory.contains('transfer')) {
      return Icons.payments;
    } else if (primaryCategory.contains('service') ||
        primaryCategory.contains('subscription')) {
      return Icons.miscellaneous_services;
    } else if (primaryCategory.contains('income') ||
        primaryCategory.contains('deposit')) {
      return Icons.attach_money;
    } else {
      return Icons.category;
    }
  }

  // Get color for transaction based on category
  Color getCategoryColor() {
    if (categories.isEmpty) return Colors.grey;

    String primaryCategory = categories[0].toLowerCase();

    if (primaryCategory.contains('food') ||
        primaryCategory.contains('restaurant') ||
        primaryCategory.contains('coffee')) {
      return Colors.orange;
    } else if (primaryCategory.contains('travel') ||
        primaryCategory.contains('hotel') ||
        primaryCategory.contains('airline')) {
      return Colors.blue;
    } else if (primaryCategory.contains('transport') ||
        primaryCategory.contains('taxi') ||
        primaryCategory.contains('uber')) {
      return Colors.indigo;
    } else if (primaryCategory.contains('shopping') ||
        primaryCategory.contains('merchandise')) {
      return Colors.pink;
    } else if (primaryCategory.contains('medical') ||
        primaryCategory.contains('health') ||
        primaryCategory.contains('doctor')) {
      return Colors.red;
    } else if (primaryCategory.contains('entertainment') ||
        primaryCategory.contains('recreation')) {
      return Colors.purple;
    } else if (primaryCategory.contains('payment') ||
        primaryCategory.contains('transfer')) {
      return Colors.green;
    } else if (primaryCategory.contains('service') ||
        primaryCategory.contains('subscription')) {
      return Colors.teal;
    } else if (primaryCategory.contains('income') ||
        primaryCategory.contains('deposit')) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }
}


