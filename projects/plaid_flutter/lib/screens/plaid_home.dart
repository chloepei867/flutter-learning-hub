import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:personal_finance_app/screens/profile_screen.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import '../models/plaid_account.dart';
import '../models/plaid_transaction.dart';
import '../services/plaid_service.dart';
import 'package:personal_finance_app/screens/account_screen.dart';
import 'package:personal_finance_app/screens/transaction_screen.dart';
import 'package:personal_finance_app/screens/notification_screen.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaidHome extends StatefulWidget {
  const PlaidHome({super.key});

  @override
  _PlaidHomeState createState() => _PlaidHomeState();
}

class _PlaidHomeState extends State<PlaidHome>
    with SingleTickerProviderStateMixin {
  int currentPageIndex = 0;
  final PlaidService _plaidService = PlaidService(
      clientId: dotenv.env['PLAID_CLIENT_ID'],
      secret: dotenv.env['PLAID_SECRET']);

  LinkTokenConfiguration? _configuration;
  StreamSubscription<LinkEvent>? _streamEvent;
  StreamSubscription<LinkExit>? _streamExit;
  StreamSubscription<LinkSuccess>? _streamSuccess;

  String _linkToken = "";
  String? _accessToken;

  List<PlaidAccount>? _accounts;
  List<PlaidTransaction>? _transactions;

  bool _isLoading = false;
  String _errorMessage = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _streamEvent = PlaidLink.onEvent.listen(_onEvent);
    _streamExit = PlaidLink.onExit.listen(_onExit);
    _streamSuccess = PlaidLink.onSuccess.listen(_onSuccess);

    _fetchLinkToken();
  }

  @override
  void dispose() {
    _streamEvent?.cancel();
    _streamExit?.cancel();
    _streamSuccess?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // Fetch Link Token
  Future<void> _fetchLinkToken() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String? token = await _plaidService.createLinkToken();
      if (token != null) {
        setState(() {
          _linkToken = token;
          _isLoading = false;
        });
        // 获取到 token 后自动打开 Plaid Link
        _createLinkTokenConfiguration();
      } else {
        setState(() {
          _errorMessage = 'Failed to get link token. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Create Link Token Configuration
  void _createLinkTokenConfiguration() {
    if (_linkToken.isEmpty) {
      setState(() {
        _errorMessage = 'Link token is empty. Please try again.';
      });
      _fetchLinkToken(); // 如果 token 为空，重新获取
      return;
    }

    setState(() {
      _configuration = LinkTokenConfiguration(
        token: _linkToken,
      );
    });

    if (_configuration != null) {
      PlaidLink.create(configuration: _configuration!); // 必须先create
      PlaidLink.open();
    } else {
      setState(() {
        _errorMessage = 'Failed to create link configuration';
      });
    }
  }

  // Event Handlers for Plaid Link
  void _onEvent(LinkEvent event) {
    final name = event.name;
    final metadata = event.metadata.description();
    print("onEvent: $name, metadata: $metadata");
  }

  void _onSuccess(LinkSuccess event) async {
    String publicToken = event.publicToken;
    final metadata = event.metadata;
    print("onSuccess: $publicToken, metadata: \\${metadata.description()}");

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String? accessToken = await _plaidService.getAccessToken(publicToken);
      if (accessToken != null) {
        // 获取 institutionId
        final institutionId = metadata.institution?.id;
        if (institutionId != null) {
          // 保存 accessToken 到 Firestore
          final userId = UserService().currentUser?.uid;
          if (userId != null) {
            await UserService.firestore.collection('users').doc(userId).set({
              'accessTokens': {institutionId: accessToken},
              'updatedAt': DateTime.now(),
            }, SetOptions(merge: true));
          }
        }
        setState(() {
          _accessToken = accessToken;
          _isLoading = false;
        });
        _fetchAccountData();
        _fetchTransactionData();
      } else {
        setState(() {
          _errorMessage = 'Failed to get access token';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _onExit(LinkExit event) {
    final metadata = event.metadata.description();
    final error = event.error?.description();
    print("onExit metadata: $metadata, error: $error");

    if (error != null) {
      setState(() {
        _errorMessage = 'Link exit error: $error';
      });
    }
  }

  // Fetch Account Data
  Future<void> _fetchAccountData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final tokens = await UserService().getAccessTokens();
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

  // Fetch Transaction Data
  Future<void> _fetchTransactionData() async {
    if (_accessToken == null) {
      setState(() {
        _errorMessage = 'No access token available';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<PlaidTransaction>? transactions =
          await _plaidService.fetchTransactionData(_accessToken!);
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching transactions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BillGuard'),
          actions: [
            if (_accessToken != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _fetchAccountData();
                  _fetchTransactionData();
                },
              ),
          ],
        ),
        body: IndexedStack(
          index: currentPageIndex,
          children: [
            _accounts == null || _accounts!.isEmpty
                ? _buildConnectionScreen()
                : const AccountsScreen(),
            const NotificationScreen(),
            ProfileScreen(
              username: 'Chloe',
              phoneNumber: '187*******90',
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Notification',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }

  // 主屏幕内容
  Widget _buildHomeScreen() {
    return Column(
      children: [
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_accounts == null)
          Center(
            child: ElevatedButton(
              onPressed: _createLinkTokenConfiguration,
              child: const Text('连接银行账户'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _accounts?.length ?? 0,
              itemBuilder: (context, index) {
                final account = _accounts![index];
                return Card(
                  child: ListTile(
                    title: Text(account.name),
                    subtitle: Text(account.type),
                    trailing:
                        Text('\$${account.balanceCurrent.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Connect with Plaid Screen
  Widget _buildConnectionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance, size: 64, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Connect Your Bank Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Link your financial accounts to get started with tracking your finances.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _createLinkTokenConfiguration,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Connect Bank Account'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Accounts Screen
  Widget _buildAccountsScreen() {
    if (_accounts == null || _accounts!.isEmpty) {
      return const Center(child: Text('No accounts found'));
    }

    // Group accounts by type
    Map<String, List<PlaidAccount>> accountsByType = {};
    for (var account in _accounts!) {
      if (!accountsByType.containsKey(account.type)) {
        accountsByType[account.type] = [];
      }
      accountsByType[account.type]!.add(account);
    }

    // Create a list of account types
    List<String> accountTypes = accountsByType.keys.toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account summary card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem(
                          'Total Accounts',
                          _accounts!.length.toString(),
                          Icons.account_balance,
                          Colors.blue,
                        ),
                        _summaryItem(
                          'Total Balance',
                          '\${_calculateTotalBalance().toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Accounts by type
            ...accountTypes.map((type) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _formatAccountType(type),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...accountsByType[type]!.map((account) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      account.getAccountTypeColor(),
                                  child: Icon(
                                    account.getAccountTypeIcon(),
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (account.officialName != null)
                                        Text(
                                          account.officialName!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  account.getFormattedBalance(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: account.type == 'loan'
                                        ? Colors.red
                                        : Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Account: ${account.getAccountNumberDisplay()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  account.getAccountTypeDisplay(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            if (account.type == 'depository' &&
                                account.balanceAvailable != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Available Balance: \${account.balanceAvailable!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatAccountType(String type) {
  // Capitalize and add plural
  return '${type.substring(0, 1).toUpperCase()}${type.substring(1)} Accounts';
}
