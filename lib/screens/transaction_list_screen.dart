import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/category_data.dart';
import '../services/transaction_service.dart';
import '../widgets/scribble_theme.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _service = TransactionService();
  List<TransactionModel> _transactions = [];
  bool _loading = true;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  double _monthTotal = 0;
  double _monthIncome = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final txs = await _service.getMonthTransactions(_selectedYear, _selectedMonth);
    final total = await _service.getMonthExpense(_selectedYear, _selectedMonth);
    final income = await _service.getMonthIncome(_selectedYear, _selectedMonth);
    setState(() {
      _transactions = txs;
      _monthTotal = total;
      _monthIncome = income;
      _loading = false;
    });
  }

  Future<void> _deleteTransaction(TransactionModel tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('皇上要销了这笔账？'),
        content: Text('${tx.category} ${tx.amount.toStringAsFixed(0)}两'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('留着')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('销账', style: TextStyle(color: ScribbleTheme.expenseColor)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.deleteTransaction(tx.id!);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScribbleTheme.primaryBg,
      appBar: AppBar(
        title: const Text('流水账'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthHeader(),
          _buildStats(),
          _buildMonthPicker(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _prevMonth,
            child: Icon(Icons.chevron_left, color: ScribbleTheme.accentDark),
          ),
          const SizedBox(width: 16),
          Text(
            '${_selectedYear}年${_selectedMonth}月',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ScribbleTheme.textPrimary),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _nextMonth,
            child: Icon(Icons.chevron_right, color: ScribbleTheme.accentDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: ScribbleTheme.scribbleCard,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('支出', style: TextStyle(fontSize: 12, color: ScribbleTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '¥${_monthTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ScribbleTheme.expenseColor,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: ScribbleTheme.scribbleLine.withValues(alpha: 0.1)),
          Expanded(
            child: Column(
              children: [
                Text('收入', style: TextStyle(fontSize: 12, color: ScribbleTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '¥${_monthIncome.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ScribbleTheme.incomeColor,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: ScribbleTheme.scribbleLine.withValues(alpha: 0.1)),
          Expanded(
            child: Column(
              children: [
                Text('结余', style: TextStyle(fontSize: 12, color: ScribbleTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '¥${(_monthIncome - _monthTotal).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: (_monthIncome - _monthTotal) >= 0 ? ScribbleTheme.incomeColor : ScribbleTheme.expenseColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    return const SizedBox(height: 8);
  }

  Widget _buildTransactionList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: ScribbleTheme.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('这个月还没有账目', style: TextStyle(fontSize: 16, color: ScribbleTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('跟奴才说一声就有了', style: TextStyle(fontSize: 14, color: ScribbleTheme.textSecondary.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    // Group transactions by date
    final grouped = <String, List<TransactionModel>>{};
    for (final tx in _transactions) {
      final key = DateFormat('MM月dd日').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ScribbleTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: _DottedLinePainter(),
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.map((tx) => _buildTransactionItem(tx)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final info = CategoryData.getInfo(tx.category);
    final isExpense = tx.type == TransactionType.expense;

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: ScribbleTheme.expenseColor.withValues(alpha: 0.2),
        child: Icon(Icons.delete_outline, color: ScribbleTheme.expenseColor),
      ),
      onDismissed: (_) => _deleteTransaction(tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ScribbleTheme.scribbleLine.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (info?.color ?? ScribbleTheme.accent).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                info?.icon ?? Icons.receipt,
                color: info?.color ?? ScribbleTheme.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.category,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  if (tx.note.isNotEmpty)
                    Text(
                      tx.note,
                      style: TextStyle(fontSize: 12, color: ScribbleTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'}¥${tx.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isExpense ? ScribbleTheme.expenseColor : ScribbleTheme.incomeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _prevMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
    _loadData();
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedYear == now.year && _selectedMonth == now.month) return;
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
    _loadData();
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ScribbleTheme.scribbleLine.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    final dashWidth = 4.0;
    final dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
