import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/plaid_account.dart';
import '../models/plaid_transaction.dart';
import 'access_token_store.dart';

const String plaidBaseUrl = 'https://sandbox.plaid.com';

class PlaidService {
  final String? clientId;
  final String? secret;
  String? _transactionCursor;

  PlaidService({this.clientId, this.secret});

  // Create a link token
  Future<String?> createLinkToken() async {
    if (clientId == null || secret == null) {
      print("Missing PLAID_CLIENT_ID or PLAID_SECRET in .env file");
      return null;
    }

    final url = Uri.parse('$plaidBaseUrl/link/token/create');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'client_id': clientId,
      'secret': secret,
      'user': {
        'client_user_id': 'user-id',
        'phone_number': '+1 415 5550123',
      },
      'client_name': 'Personal Finance App',
      'products': ["auth", "transactions", "investments"],
      'transactions': {
        'days_requested': 730,
      },
      'country_codes': ['US'],
      'language': 'en',
      'webhook': 'https://sample-web-hook.com',
      'redirect_uri': 'http://localhost:3000',
      // 'account_filters': {
      //   'depository': {
      //     'account_subtypes': ['checking', 'savings'],
      //   },
      //   'credit': {
      //     'account_subtypes': ['credit card'],
      //   }
      // }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['link_token'];
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  // Exchange public token for access token
  Future<String?> getAccessToken(String publicToken) async {
    if (clientId == null || secret == null) {
      print("Missing PLAID_CLIENT_ID or PLAID_SECRET");
      return null;
    }

    final url = Uri.parse('$plaidBaseUrl/item/public_token/exchange');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "client_id": clientId,
      "secret": secret,
      "public_token": publicToken,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['access_token'];
        final itemId = responseData['item_id'];
        // 存储到全局单例
        accessTokenStore.accessToken = accessToken;
        accessTokenStore.itemId = itemId;
        print('Saving access_token: $accessToken');
        print('Saving item_id: $itemId');
        return accessToken;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  // Fetch account data
  Future<List<PlaidAccount>?> fetchAccountData(String accessToken) async {
    if (clientId == null || secret == null) {
      print("Missing PLAID_CLIENT_ID or PLAID_SECRET");
      return null;
    }

    final url = Uri.parse('$plaidBaseUrl/accounts/get');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "client_id": clientId,
      "secret": secret,
      "access_token": accessToken,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accountsList = responseData['accounts'] as List;
        return accountsList
            .map((account) => PlaidAccount.fromJson(account))
            .toList();
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  // Fetch transaction data with sync endpoint
  Future<List<PlaidTransaction>?> fetchTransactionData(
      String accessToken) async {
    if (clientId == null || secret == null) {
      print("Missing PLAID_CLIENT_ID or PLAID_SECRET");
      return null;
    }

    final url = Uri.parse('$plaidBaseUrl/transactions/sync');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "client_id": clientId,
      "secret": secret,
      "access_token": accessToken,
      "cursor": _transactionCursor, // Use stored cursor for pagination
      "count": 100,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Store the cursor for next sync
        if (responseData['next_cursor'] != null) {
          _transactionCursor = responseData['next_cursor'];
        }

        List<PlaidTransaction> transactions = [];

        // Process added transactions
        if (responseData['added'] != null) {
          final addedList = responseData['added'] as List;
          transactions.addAll(
              addedList.map((tx) => PlaidTransaction.fromJson(tx)).toList());
        }

        // Process modified transactions
        if (responseData['modified'] != null) {
          final modifiedList = responseData['modified'] as List;
          transactions.addAll(
              modifiedList.map((tx) => PlaidTransaction.fromJson(tx)).toList());
        }

        // Note: We don't need to explicitly handle removed transactions in this implementation
        // but in a real app you would need to remove them from your local database

        return transactions;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  // Alternative method using /transactions/get endpoint
  Future<List<PlaidTransaction>?> fetchTransactionsWithGet(
      String accessToken) async {
    if (clientId == null || secret == null) {
      print("Missing PLAID_CLIENT_ID or PLAID_SECRET");
      return null;
    }

    final url = Uri.parse('$plaidBaseUrl/transactions/get');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "client_id": clientId,
      "secret": secret,
      "access_token": accessToken,
      "options": {"count": 100, "offset": 0},
      "start_date": _getStartDate(),
      "end_date": _getEndDate(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final transactionsList = responseData['transactions'] as List;
        return transactionsList
            .map((transaction) => PlaidTransaction.fromJson(transaction))
            .toList();
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  String _getStartDate() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return '${thirtyDaysAgo.year}-${thirtyDaysAgo.month.toString().padLeft(2, '0')}-${thirtyDaysAgo.day.toString().padLeft(2, '0')}';
  }

  String _getEndDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Fetch investment holdings
  Future<Map<String, dynamic>> fetchInvestmentHoldings(
      String accessToken) async {
    if (clientId == null || secret == null) {
      print("Missing PLAID_CLIENT_ID or PLAID_SECRET");
      throw Exception('Missing Plaid credentials');
    }

    final url = Uri.parse('$plaidBaseUrl/investments/holdings/get');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': clientId,
        'secret': secret,
        'access_token': accessToken,
        // 'options': {
        //   'account_ids': [] // 空数组表示获取所有账户
        // }
      }),
    );
    if (response.statusCode == 200) {
      print('Plaid investments response: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('Plaid investments error: ${response.body}');
      throw Exception('Failed to fetch investment holdings');
    }
  }

  // fetch investment transactions
  Future<Map<String, dynamic>> fetchInvestmentTransactions(
      String accessToken) async {
    if (clientId == null || secret == null) {
      print("Missing PLAID_CLIENT_ID or PLAID_SECRET");
      throw Exception('Missing Plaid credentials');
    }

    final url = Uri.parse('$plaidBaseUrl/investments/transactions/get');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': clientId,
        'secret': secret,
        'access_token': accessToken,
        'start_date': _getStartDate(),
        'end_date': _getEndDate(),
        'options': {
          'account_ids': [] // 空数组表示获取所有账户
        }
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Plaid investments error: ${response.body}');
      throw Exception('Failed to fetch investment transactions');
    }
  }
}
