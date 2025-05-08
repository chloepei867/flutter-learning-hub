import 'package:flutter/material.dart';
import 'account_screen.dart';
import '../models/plaid_account.dart';
import '../screens/transaction_screen.dart';
import '../screens/investment_screen.dart';
import '../services/access_token_store.dart';
import '../services/plaid_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String phoneNumber;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final PlaidService _plaidService;
  List<PlaidAccount>? _accounts;
  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  int selectedMonth = DateTime.now().month;
  double expenseTotal = 0.0;
  double incomeTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _plaidService = PlaidService(
      clientId: dotenv.env['PLAID_CLIENT_ID'] ?? '',
      secret: dotenv.env['PLAID_SECRET'] ?? '',
    );
    _accessToken = accessTokenStore.accessToken;
    // _fetchAccounts();
  }

  // Future<void> _fetchAccounts() async {
  //   if (_accessToken == null || _accessToken!.isEmpty) {
  //     setState(() {
  //       _errorMessage = 'No access token available';
  //     });
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     final accounts = await _plaidService.fetchAccountData(_accessToken!);
  //     setState(() {
  //       _accounts = accounts;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'Error fetching accounts: $e';
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // User info card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Colors.white,
            child: Row(
              children: [
                // CircleAvatar(
                //   radius: 30,
                //   backgroundImage: AssetImage('assets/profile_image.png'),
                //   backgroundColor: Colors.blue[100],
                //   child: widget.username.isEmpty
                //       ? Icon(Icons.person, size: 30, color: Colors.blue)
                //       : null,
                // ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.phoneNumber,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: Colors.grey[400], size: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Main menu items
          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.show_chart,
              iconColor: Colors.blue,
              title: 'Cash Flow',
              onTap: () {
                // TODO: Navigate to Cash Flow
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.receipt_long,
              iconColor: Colors.orange,
              title: 'Transactions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransactionScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.credit_card,
              iconColor: Colors.blueAccent,
              title: 'Accounts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountsScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.trending_up,
              iconColor: Colors.green,
              title: 'Investments',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InvestmentScreen(),
                  ),
                );
              },
            ),
          ]),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            trailing ??
                Icon(Icons.arrow_forward_ios,
                    color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
    );
  }

  void fetchTransactions() {
    // Implementation of fetchTransactions method
  }
}
