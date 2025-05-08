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
          final holdingsData =
              await plaidService.fetchInvestmentHoldings(token);
          print('Plaid investments holdings: ${holdingsData}');

          // 暂时注释掉获取交易数据
          // final transactionsData = await plaidService.fetchInvestmentTransactions(token);
          // print('Plaid investments transactions: ${transactionsData}');

          if (holdingsData['holdings'] != null) {
            allHoldings.addAll((holdingsData['holdings'] as List)
                .map((h) => InvestmentHolding.fromJson(h)));
          }
          if (holdingsData['securities'] != null) {
            allSecurities.addAll((holdingsData['securities'] as List)
                .map((s) => InvestmentSecurity.fromJson(s)));
          }
          // 暂时注释掉处理交易数据
          // if (transactionsData['investment_transactions'] != null) {
          //   allTransactions.addAll(
          //       (transactionsData['investment_transactions'] as List)
          //           .map((t) => InvestmentTransaction.fromJson(t)));
          // }
        } catch (e) {
          print('Error fetching data for token: $e');
          // 继续处理其他token
        }
      }

      // 暂时注释掉交易记录排序
      // allTransactions.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        holdings = allHoldings;
        securities = allSecurities;
        // transactions = allTransactions;
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
                            subtitle: Text(
                                'Quantity: ${h.quantity}, Value: ${h.institutionValue} ${h.isoCurrencyCode}'),
                            trailing: Text(sec?.tickerSymbol ?? ''),
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
                              subtitle: Text(
                                  'Type: ${s.type}, Ticker: ${s.tickerSymbol ?? '-'}'),
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
                                    'Amount: ${t.amount} ${t.isoCurrencyCode}'),
                                Text('Date: ${t.date}'),
                                Text('Security: ${sec?.name ?? t.securityId}'),
                                Text('Type: ${t.type}'),
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
