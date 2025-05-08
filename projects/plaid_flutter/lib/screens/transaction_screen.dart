import 'package:flutter/material.dart';
import '../models/plaid_transaction.dart';
import '../models/counterparty_data.dart';
import '../utils/formatters.dart';
import '../widgets/summary_card.dart';
import '../services/plaid_service.dart';
import '../services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import '../screens/analysis_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String searchQuery = '';
  List<PlaidTransaction> transactions = [];
  bool isLoading = true;
  String? error;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  DateTime? customStartDate;
  DateTime? customEndDate;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final tokens = await UserService().getAccessTokens();
      if (tokens.isEmpty) {
        setState(() {
          error = 'No access token. Please connect your account first.';
          isLoading = false;
        });
        return;
      }
      final plaidService = PlaidService(
        clientId: dotenv.env['PLAID_CLIENT_ID'],
        secret: dotenv.env['PLAID_SECRET'],
      );
      List<PlaidTransaction> allTransactions = [];
      for (final token in tokens.values) {
        final txs = await plaidService.fetchTransactionData(token);
        if (txs != null) {
          allTransactions.addAll(txs);
        }
      }
      setState(() {
        transactions = allTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<PlaidTransaction> get filteredByMonth {
    if (customStartDate != null && customEndDate != null) {
      return transactions.where((tx) {
        final date = DateTime.tryParse(tx.date);
        return date != null &&
            !date.isBefore(customStartDate!) &&
            !date.isAfter(customEndDate!);
      }).toList();
    }
    return transactions.where((tx) {
      final date = DateTime.tryParse(tx.date);
      return date != null &&
          date.year == selectedYear &&
          date.month == selectedMonth;
    }).toList();
  }

  double get expenseTotal => filteredByMonth
      .where((tx) => tx.amount < 0)
      .fold(0.0, (sum, tx) => sum + tx.amount.abs());
  double get incomeTotal => filteredByMonth
      .where((tx) => tx.amount > 0)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  @override
  Widget build(BuildContext context) {
    final filtered = filteredByMonth
        .where(
            (tx) => tx.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // 月份选择和统计分两行
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result =
                        await showModalBottomSheet<Map<String, dynamic>>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        int tempYear = selectedYear;
                        int tempMonth = selectedMonth;
                        DateTime? customStart;
                        DateTime? customEnd;
                        int tabIndex = 0;
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return Container(
                              height: 420,
                              child: Column(
                                children: [
                                  // TabBar
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setModalState(() => tabIndex = 0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: tabIndex == 0
                                                      ? Colors.blue
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            child: Text('月份选择',
                                                style: TextStyle(
                                                    color: tabIndex == 0
                                                        ? Colors.blue
                                                        : Colors.black)),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setModalState(() => tabIndex = 1),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: tabIndex == 1
                                                      ? Colors.blue
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            child: Text('自定义时间',
                                                style: TextStyle(
                                                    color: tabIndex == 1
                                                        ? Colors.blue
                                                        : Colors.black)),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  if (tabIndex == 0)
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: CupertinoPicker(
                                              scrollController:
                                                  FixedExtentScrollController(
                                                      initialItem:
                                                          DateTime.now().year -
                                                              tempYear),
                                              itemExtent: 32,
                                              onSelectedItemChanged: (index) {
                                                setModalState(() {
                                                  tempYear =
                                                      DateTime.now().year -
                                                          index;
                                                });
                                              },
                                              children: List.generate(5, (i) {
                                                int year =
                                                    DateTime.now().year - i;
                                                return Center(
                                                    child: Text('$year'));
                                              }),
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoPicker(
                                              scrollController:
                                                  FixedExtentScrollController(
                                                      initialItem:
                                                          tempMonth - 1),
                                              itemExtent: 32,
                                              onSelectedItemChanged: (index) {
                                                setModalState(() {
                                                  tempMonth = index + 1;
                                                });
                                              },
                                              children: List.generate(
                                                  12,
                                                  (i) => Center(
                                                      child:
                                                          Text('${i + 1}月'))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            const Text('交易时间'),
                                            Row(
                                              children: [
                                                OutlinedButton(
                                                  onPressed: () {
                                                    final now = DateTime.now();
                                                    setModalState(() {
                                                      customStart =
                                                          now.subtract(
                                                              const Duration(
                                                                  days: 90));
                                                      customEnd = now;
                                                    });
                                                  },
                                                  child: const Text('近三月'),
                                                ),
                                                const SizedBox(width: 8),
                                                OutlinedButton(
                                                  onPressed: () {
                                                    final now = DateTime.now();
                                                    setModalState(() {
                                                      customStart =
                                                          now.subtract(
                                                              const Duration(
                                                                  days: 180));
                                                      customEnd = now;
                                                    });
                                                  },
                                                  child: const Text('近半年'),
                                                ),
                                                const SizedBox(width: 8),
                                                OutlinedButton(
                                                  onPressed: () {
                                                    final now = DateTime.now();
                                                    setModalState(() {
                                                      customStart =
                                                          now.subtract(
                                                              const Duration(
                                                                  days: 365));
                                                      customEnd = now;
                                                    });
                                                  },
                                                  child: const Text('近一年'),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            const Text('自定义'),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      final picked =
                                                          await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            customStart ??
                                                                DateTime.now(),
                                                        firstDate:
                                                            DateTime(2020),
                                                        lastDate:
                                                            DateTime.now(),
                                                      );
                                                      if (picked != null) {
                                                        setModalState(() {
                                                          customStart = picked;
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                      decoration:
                                                          const BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .blue)),
                                                      ),
                                                      child: Text(
                                                        customStart != null
                                                            ? DateFormat(
                                                                    'yyyy-MM-dd')
                                                                .format(
                                                                    customStart!)
                                                            : '开始时间',
                                                        style: TextStyle(
                                                            color:
                                                                customStart !=
                                                                        null
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: Text('至'),
                                                ),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      final picked =
                                                          await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            customEnd ??
                                                                DateTime.now(),
                                                        firstDate:
                                                            DateTime(2020),
                                                        lastDate:
                                                            DateTime.now(),
                                                      );
                                                      if (picked != null) {
                                                        setModalState(() {
                                                          customEnd = picked;
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                      decoration:
                                                          const BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .blue)),
                                                      ),
                                                      child: Text(
                                                        customEnd != null
                                                            ? DateFormat(
                                                                    'yyyy-MM-dd')
                                                                .format(
                                                                    customEnd!)
                                                            : '结束时间',
                                                        style: TextStyle(
                                                            color: customEnd !=
                                                                    null
                                                                ? Colors.black
                                                                : Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text('最长可查找时间跨度一年的交易',
                                                style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (tabIndex == 0) {
                                            Navigator.pop(context, {
                                              'type': 'month',
                                              'year': tempYear,
                                              'month': tempMonth
                                            });
                                          } else {
                                            Navigator.pop(context, {
                                              'type': 'custom',
                                              'start': customStart,
                                              'end': customEnd
                                            });
                                          }
                                        },
                                        child: const Text('确定'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                    if (result != null) {
                      if (result['type'] == 'month') {
                        setState(() {
                          selectedYear = result['year'];
                          selectedMonth = result['month'];
                          customStartDate = null;
                          customEndDate = null;
                        });
                      } else if (result['type'] == 'custom') {
                        setState(() {
                          customStartDate = result['start'];
                          customEndDate = result['end'];
                        });
                      }
                    }
                  },
                  child: Row(
                    children: [
                      Text('$selectedMonth月',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnalysisScreen(
                          initialYear: customStartDate != null
                              ? customStartDate!.year
                              : selectedYear,
                          initialMonth: customStartDate != null
                              ? customStartDate!.month
                              : selectedMonth,
                        ),
                      ),
                    );
                  },
                  child: const Text('收支分析'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: Row(
              children: [
                Text(
                    '支出 ${expenseTotal.toStringAsFixed(2)}  收入 ${incomeTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // 交易列表
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text('Error: $error'))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  tx.getCategoryColor().withOpacity(0.2),
                              child: Icon(tx.getCategoryIcon(),
                                  color: tx.getCategoryColor()),
                            ),
                            title: Text(tx.name,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                                '${tx.getPrimaryCategory()}  •  ${tx.date}'),
                            trailing: Text(
                              tx.amount.toStringAsFixed(2),
                              style: TextStyle(
                                color:
                                    tx.amount < 0 ? Colors.black : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              // TODO: 跳转到交易详情
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
