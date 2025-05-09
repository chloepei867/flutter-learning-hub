import 'package:flutter/material.dart';
import '../models/investment_holding.dart';
import '../models/investment_security.dart';
import '../models/investment_transaction.dart';
import '../services/plaid_service.dart';
import '../services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<InvestmentHolding> holdings = [];
  List<InvestmentSecurity> securities = [];
  List<InvestmentTransaction> transactions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchInvestmentData();
  }

  Future<void> fetchInvestmentData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final tokens = await UserService().getAccessTokens();
      if (tokens.isEmpty) {
        setState(() {
          error = '没有访问令牌。请先连接您的账户。';
          isLoading = false;
        });
        return;
      }
      final plaidService = PlaidService(
        clientId: dotenv.env['PLAID_CLIENT_ID'],
        secret: dotenv.env['PLAID_SECRET'],
      );
      List<InvestmentHolding> allHoldings = [];
      List<InvestmentSecurity> allSecurities = [];
      List<InvestmentTransaction> allTransactions = [];

      for (final token in tokens.values) {
        try {
          print('Fetching data for token: $token');

          final holdingsData =
              await plaidService.fetchInvestmentHoldings(token);
          print('Holdings data: ${holdingsData.toString()}');

          // Get investment transactions data
          final transactionsData =
              await plaidService.fetchInvestmentTransactions(token);
          print('Transactions data: ${transactionsData.toString()}');

          if (holdingsData['holdings'] != null) {
            print(
                'Processing holdings: ${holdingsData['holdings'].length} items');
            allHoldings.addAll((holdingsData['holdings'] as List)
                .map((h) => InvestmentHolding.fromJson(h)));
          } else {
            print('No holdings data found');
          }

          if (holdingsData['securities'] != null) {
            print(
                'Processing securities: ${holdingsData['securities'].length} items');
            allSecurities.addAll((holdingsData['securities'] as List)
                .map((s) => InvestmentSecurity.fromJson(s)));
          } else {
            print('No securities data found');
          }

          if (transactionsData['investment_transactions'] != null) {
            print(
                'Processing transactions: ${transactionsData['investment_transactions'].length} items');
            allTransactions.addAll(
                (transactionsData['investment_transactions'] as List)
                    .map((t) => InvestmentTransaction.fromJson(t)));
          } else {
            print('No transactions data found');
          }
        } catch (e) {
          print('Error fetching data for token: $e');
          // Continue with other tokens
        }
      }

      print('Final data counts:');
      print('Holdings: ${allHoldings.length}');
      print('Securities: ${allSecurities.length}');
      print('Transactions: ${allTransactions.length}');

      // Sort transactions by date (newest first)
      allTransactions.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        holdings = allHoldings;
        securities = allSecurities;
        transactions = allTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = '获取投资数据时出错：$e';
        isLoading = false;
      });
    }
  }

  InvestmentSecurity? getSecurityById(String id) {
    return securities.firstWhere((s) => s.securityId == id,
        orElse: () => InvestmentSecurity(
              securityId: id,
              name: 'Unknown',
              type: '-',
              isoCurrencyCode: '-',
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investments'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : RefreshIndicator(
                  onRefresh: fetchInvestmentData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('Holdings',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      if (holdings.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No holdings found'),
                        ),
                      ...holdings.map((h) {
                        final sec = getSecurityById(h.securityId);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(sec?.name ?? h.securityId),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Quantity: ${h.quantity.toStringAsFixed(4)}'),
                                Text(
                                    'Value: ${h.institutionValue.toStringAsFixed(2)} ${h.isoCurrencyCode}'),
                                if (h.costBasis != null)
                                  Text(
                                      'Cost Basis: ${h.costBasis!.toStringAsFixed(2)} ${h.isoCurrencyCode}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(sec?.tickerSymbol ?? ''),
                                if (sec?.closePrice != null)
                                  Text(
                                      '\$${sec!.closePrice!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      const Text('Securities',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      if (securities.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No securities found'),
                        ),
                      ...securities.map((s) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(s.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Type: ${s.type}'),
                                  if (s.tickerSymbol != null)
                                    Text('Ticker: ${s.tickerSymbol}'),
                                  if (s.sector != null)
                                    Text('Sector: ${s.sector}'),
                                  if (s.industry != null)
                                    Text('Industry: ${s.industry}'),
                                ],
                              ),
                              trailing: s.closePrice != null
                                  ? Text(
                                      '\$${s.closePrice!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold))
                                  : null,
                              isThreeLine: true,
                            ),
                          )),
                      const SizedBox(height: 20),
                      const Text('Transactions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      if (transactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No transactions found'),
                        ),
                      ...transactions.map((t) {
                        final sec = getSecurityById(t.securityId);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(t.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Amount: ${t.amount.toStringAsFixed(2)} ${t.isoCurrencyCode}'),
                                Text('Date: ${t.date}'),
                                Text('Type: ${t.type} (${t.subtype})'),
                                if (t.quantity != 0)
                                  Text(
                                      'Quantity: ${t.quantity.toStringAsFixed(4)}'),
                                if (t.price != 0)
                                  Text('Price: ${t.price.toStringAsFixed(2)}'),
                                if (t.fees != 0)
                                  Text('Fees: ${t.fees.toStringAsFixed(2)}'),
                                if (sec != null)
                                  Text(
                                      'Security: ${sec.name} (${sec.tickerSymbol ?? 'N/A'})'),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
