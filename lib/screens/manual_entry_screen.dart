import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category_data.dart';
import '../services/transaction_service.dart';
import '../widgets/scribble_theme.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final TransactionService _service = TransactionService();
  TransactionType _type = TransactionType.expense;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('皇上，请填个正经的数目')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('皇上，请选个门类')),
      );
      return;
    }

    await _service.addTransaction(
      category: _selectedCategory!,
      amount: amount,
      type: _type,
      note: _noteController.text.isNotEmpty ? _noteController.text : '${_selectedCategory} ${amount.toStringAsFixed(0)}两',
      date: _selectedDate,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _type == TransactionType.expense
                ? '嗻！${_selectedCategory} ${amount.toStringAsFixed(0)}两，奴才记下了'
                : '嗻！${_selectedCategory} ${amount.toStringAsFixed(0)}两，入账了',
          ),
          backgroundColor: ScribbleTheme.accent,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseCats = CategoryData.expenseCategoryNames;
    final incomeCats = CategoryData.incomeCategoryNames;
    final currentCats = _type == TransactionType.expense ? expenseCats : incomeCats;

    return Scaffold(
      backgroundColor: ScribbleTheme.primaryBg,
      appBar: AppBar(
        title: const Text('记一笔'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle
            Row(
              children: [
                _buildTypeToggle('支出', TransactionType.expense),
                const SizedBox(width: 12),
                _buildTypeToggle('收入', TransactionType.income),
              ],
            ),
            const SizedBox(height: 24),

            // Category grid
            Text('门类', style: TextStyle(fontSize: 14, color: ScribbleTheme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: currentCats.map((cat) => _buildCategoryChip(cat)).toList(),
            ),
            const SizedBox(height: 24),

            // Amount
            Text('银子', style: TextStyle(fontSize: 14, color: ScribbleTheme.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '¥ ',
                prefixStyle: TextStyle(fontSize: 20, color: ScribbleTheme.accent, fontWeight: FontWeight.bold),
                hintStyle: TextStyle(fontSize: 28, color: ScribbleTheme.textSecondary.withValues(alpha: 0.3)),
              ),
              style: TextStyle(fontSize: 28, color: ScribbleTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Date
            Text('日期', style: TextStyle(fontSize: 14, color: ScribbleTheme.textSecondary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: ScribbleTheme.categoryBadge,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: ScribbleTheme.accentDark),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Note
            Text('备注（可不写）', style: TextStyle(fontSize: 14, color: ScribbleTheme.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: '比如：中午和同事吃的牛肉面',
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ScribbleTheme.accent,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('记好了', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(String label, TransactionType type) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() {
        _type = type;
        _selectedCategory = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? (type == TransactionType.expense ? ScribbleTheme.expenseColor : ScribbleTheme.incomeColor) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : ScribbleTheme.scribbleLine.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : ScribbleTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String cat) {
    final info = CategoryData.getInfo(cat);
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (info?.color ?? ScribbleTheme.accent).withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? (info?.color ?? ScribbleTheme.accent) : ScribbleTheme.scribbleLine.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (info != null)
              Icon(info.icon, size: 18, color: info.color),
            const SizedBox(width: 6),
            Text(cat, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: ScribbleTheme.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}
