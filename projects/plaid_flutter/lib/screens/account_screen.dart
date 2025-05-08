import 'package:flutter/material.dart';
import '../models/plaid_account.dart';
import '../services/user_service.dart';
import '../services/plaid_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'plaid_home.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final UserService _userService = UserService();
  late final PlaidService _plaidService;
  List<PlaidAccount> _accounts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _plaidService = PlaidService(
      clientId: dotenv.env['PLAID_CLIENT_ID'],
      secret: dotenv.env['PLAID_SECRET'],
    );
    _fetchAllAccounts();
  }

  Future<void> _fetchAllAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tokens = await _userService.getAccessTokens();
      List<PlaidAccount> allAccounts = [];
      for (final token in tokens.values) {
        final accounts = await _plaidService.fetchAccountData(token);
        if (accounts != null) {
          allAccounts.addAll(accounts);
        }
      }
      setState(() {
        _accounts = allAccounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching accounts: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Cards'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Expanded(
                      child: _accounts.isEmpty
                          ? const Center(child: Text('No accounts found'))
                          : ListView.builder(
                              itemCount: _accounts.length,
                              itemBuilder: (context, index) {
                                final account = _accounts[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400],
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            account.getAccountTypeIcon(),
                                            color: Colors.blue[400],
                                            size: 28,
                                          ),
                                        ),
                                        title: Text(
                                          '${account.name}(${account.getAccountNumberDisplay()})',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          account.type,
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                        trailing: const Icon(
                                            Icons.chevron_right,
                                            color: Colors.white),
                                        onTap: () {
                                          // TODO: Card details
                                        },
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {},
                                              child: const Text('Statement',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {},
                                              child: const Text('Card No.',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {},
                                              child: Text(
                                                account.type == 'Credit Card'
                                                    ? 'Repay'
                                                    : 'Deposit',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Bank Card'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PlaidHome(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.share),
                              label: const Text('Share with Friends'),
                              onPressed: () {
                                // TODO: Share logic
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
