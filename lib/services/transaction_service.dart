import '../models/transaction_model.dart';
import '../db/database_helper.dart';

class TransactionService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<TransactionModel> addTransaction({
    required String category,
    required double amount,
    required TransactionType type,
    String note = '',
    DateTime? date,
  }) async {
    final tx = TransactionModel(
      category: category,
      amount: amount,
      type: type,
      note: note,
      date: date,
    );
    final id = await _db.insertTransaction(tx);
    return tx.copyWith(id: id);
  }

  Future<List<TransactionModel>> getRecentTransactions({int count = 50}) async {
    return await _db.getTransactions(limit: count);
  }

  Future<List<TransactionModel>> getMonthTransactions(int year, int month) async {
    return await _db.getTransactionsByMonth(year, month);
  }

  Future<List<TransactionModel>> getTodayTransactions() async {
    return await _db.getTodayTransactions();
  }

  Future<double> getMonthExpense(int year, int month) async {
    return await _db.getTotalByMonth(year, month, TransactionType.expense);
  }

  Future<double> getMonthIncome(int year, int month) async {
    return await _db.getTotalByMonth(year, month, TransactionType.income);
  }

  Future<Map<String, double>> getCategoryTotals(int year, int month) async {
    return await _db.getCategoryTotalsByMonth(year, month);
  }

  Future<void> deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
  }

  // Budget
  Future<void> setBudget(String category, double limit, int month, int year) async {
    final budget = BudgetModel(category: category, limit: limit, month: month, year: year);
    await _db.setBudget(budget);
  }

  Future<BudgetModel?> getBudget(String category, int month, int year) async {
    return await _db.getBudget(category, month, year);
  }

  Future<List<BudgetModel>> getAllBudgets(int month, int year) async {
    return await _db.getAllBudgets(month, year);
  }
}
