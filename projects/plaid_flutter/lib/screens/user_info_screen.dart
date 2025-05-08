import 'package:flutter/material.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Info Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/women/44.jpg',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chloe Parker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'chloe.parker@example.com',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoItem('Accounts', '3'),
                        _buildInfoItem('Balance', '\$12,345'),
                        _buildInfoItem('Since', '2024'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Settings List
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSettingTile(
                  context,
                  'Transactions',
                  Icons.receipt_long,
                  () {
                    // TODO: Navigate to transactions
                  },
                ),
                _buildSettingTile(
                  context,
                  'Investments',
                  Icons.trending_up,
                  () {
                    // TODO: Navigate to investments
                  },
                ),
                _buildSettingTile(
                  context,
                  'Cash Flow',
                  Icons.account_balance_wallet,
                  () {
                    // TODO: Navigate to cash flow
                  },
                ),
                _buildSettingTile(
                  context,
                  'Settings',
                  Icons.settings,
                  () {
                    // TODO: Navigate to settings
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
