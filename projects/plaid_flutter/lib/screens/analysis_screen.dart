import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/plaid_transaction.dart';
import '../services/plaid_service.dart';
import '../services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AnalysisScreen extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final bool initialIsExpense;

  const AnalysisScreen({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    this.initialIsExpense = true,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  bool isExpense = true;
  List<PlaidTransaction> transactions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialYear;
    selectedMonth = widget.initialMonth;
    isExpense = widget.initialIsExpense;
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
    return transactions.where((tx) {
      final date = DateTime.tryParse(tx.date);
      return date != null &&
          date.year == selectedYear &&
          date.month == selectedMonth &&
          (isExpense ? tx.amount < 0 : tx.amount > 0);
    }).toList();
  }

  Map<String, List<PlaidTransaction>> get groupedByCategory {
    final map = <String, List<PlaidTransaction>>{};
    for (final tx in filteredByMonth) {
      final cat = tx.getPrimaryCategory();
      map.putIfAbsent(cat, () => []).add(tx);
    }
    return map;
  }

  List<_CategoryStat> get categoryStats {
    final total =
        filteredByMonth.fold<double>(0, (sum, tx) => sum + tx.amount.abs());
    final stats = groupedByCategory.entries.map((e) {
      final sum = e.value.fold<double>(0, (s, tx) => s + tx.amount.abs());
      return _CategoryStat(
        category: e.key,
        amount: sum,
        percent: total > 0 ? sum / total : 0,
        count: e.value.length,
      );
    }).toList();
    stats.sort((a, b) => b.amount.compareTo(a.amount));
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收支分析'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 年月选择和支出/收入切换
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await showModalBottomSheet<Map<String, int>>(
                      context: context,
                      builder: (context) {
                        int tempYear = selectedYear;
                        int tempMonth = selectedMonth;
                        return Container(
                          height: 300,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                      initialItem:
                                          DateTime.now().year - tempYear),
                                  itemExtent: 32,
                                  onSelectedItemChanged: (index) {
                                    tempYear = DateTime.now().year - index;
                                  },
                                  children: List.generate(5, (i) {
                                    int year = DateTime.now().year - i;
                                    return Center(child: Text('$year'));
                                  }),
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                      initialItem: tempMonth - 1),
                                  itemExtent: 32,
                                  onSelectedItemChanged: (index) {
                                    tempMonth = index + 1;
                                  },
                                  children: List.generate(12,
                                      (i) => Center(child: Text('${i + 1}月'))),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    if (result != null) {
                      setState(() {
                        selectedYear = result['year']!;
                        selectedMonth = result['month']!;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Text('${selectedYear}年${selectedMonth}月',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                const Spacer(),
                ToggleButtons(
                  isSelected: [isExpense, !isExpense],
                  onPressed: (index) {
                    setState(() {
                      isExpense = index == 0;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('支出'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('收入'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // TabBar（只显示收支分类）
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Text('收支分类',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 环形图和分类列表
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text('Error: $error'))
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 环形图（可用占位）
                              Center(
                                child: SizedBox(
                                  height: 180,
                                  child: _DonutChart(stats: categoryStats),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...categoryStats.asMap().entries.map((entry) {
                                final i = entry.key + 1;
                                final stat = entry.value;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Text(
                                          '$i. ${stat.category} ${(stat.percent * 100).toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const Spacer(),
                                      Text(
                                          '¥${stat.amount.toStringAsFixed(2)}(${stat.count}笔)',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStat {
  final String category;
  final double amount;
  final double percent;
  final int count;
  _CategoryStat(
      {required this.category,
      required this.amount,
      required this.percent,
      required this.count});
}

class _DonutChart extends StatelessWidget {
  final List<_CategoryStat> stats;
  const _DonutChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }
    // 这里只用占位环形图，后续可用fl_chart等库美化
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: CircularProgressIndicator(
            value: 1,
            strokeWidth: 32,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[200]!),
          ),
        ),
        ..._buildSegments(),
      ],
    );
  }

  List<Widget> _buildSegments() {
    double start = 0;
    final widgets = <Widget>[];
    for (final stat in stats) {
      widgets.add(Positioned.fill(
        child: CustomPaint(
          painter: _DonutSegmentPainter(
            startAngle: start,
            sweep: stat.percent * 360,
            color: _getColor(stat.category),
          ),
        ),
      ));
      start += stat.percent * 360;
    }
    return widgets;
  }

  Color _getColor(String category) {
    // 可自定义不同类别颜色
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.amber,
      Colors.teal
    ];
    return colors[
        stats.indexWhere((s) => s.category == category) % colors.length];
  }
}

class _DonutSegmentPainter extends CustomPainter {
  final double startAngle;
  final double sweep;
  final Color color;
  _DonutSegmentPainter(
      {required this.startAngle, required this.sweep, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32;
    canvas.drawArc(rect, (startAngle - 90) * 3.1415926 / 180,
        sweep * 3.1415926 / 180, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
