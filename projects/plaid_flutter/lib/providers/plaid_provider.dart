import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plaid_account.dart';
import '../models/plaid_transaction.dart';
import '../services/plaid_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlaidState {
  final String? linkToken;
  final String? accessToken;
  final List<PlaidAccount>? accounts;
  final List<PlaidTransaction>? transactions;
  final bool isLoading;
  final String? errorMessage;

  PlaidState({
    this.linkToken,
    this.accessToken,
    this.accounts,
    this.transactions,
    this.isLoading = false,
    this.errorMessage,
  });

  PlaidState copyWith({
    String? linkToken,
    String? accessToken,
    List<PlaidAccount>? accounts,
    List<PlaidTransaction>? transactions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlaidState(
      linkToken: linkToken ?? this.linkToken,
      accessToken: accessToken ?? this.accessToken,
      accounts: accounts ?? this.accounts,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PlaidNotifier extends StateNotifier<PlaidState> {
  final PlaidService _plaidService;

  PlaidNotifier()
      : _plaidService = PlaidService(
          clientId: dotenv.env['PLAID_CLIENT_ID'],
          secret: dotenv.env['PLAID_SECRET'],
        ),
        super(PlaidState());

  Future<void> fetchLinkToken() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final token = await _plaidService.createLinkToken();
      if (token != null) {
        state = state.copyWith(linkToken: token, isLoading: false);
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to get link token',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error: $e',
        isLoading: false,
      );
    }
  }

  Future<void> getAccessToken(String publicToken) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final accessToken = await _plaidService.getAccessToken(publicToken);
      if (accessToken != null) {
        state = state.copyWith(accessToken: accessToken, isLoading: false);
        await fetchAccountData();
        await fetchTransactionData();
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to get access token',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error: $e',
        isLoading: false,
      );
    }
  }

  Future<void> fetchAccountData() async {
    if (state.accessToken == null) {
      state = state.copyWith(errorMessage: 'No access token available');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final accounts = await _plaidService.fetchAccountData(state.accessToken!);
      state = state.copyWith(accounts: accounts, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error fetching accounts: $e',
        isLoading: false,
      );
    }
  }

  Future<void> fetchTransactionData() async {
    if (state.accessToken == null) {
      state = state.copyWith(errorMessage: 'No access token available');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final transactions =
          await _plaidService.fetchTransactionData(state.accessToken!);
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error fetching transactions: $e',
        isLoading: false,
      );
    }
  }
}

final plaidProvider = StateNotifierProvider<PlaidNotifier, PlaidState>((ref) {
  return PlaidNotifier();
});
