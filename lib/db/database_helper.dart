import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'neiwufu.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        note TEXT DEFAULT '',
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        limit REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');

    // Index for date queries
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
  }

  // Transaction CRUD
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions({int? limit, int? offset}) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];
    final maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return getTransactionsByDateRange(start, end);
  }

  Future<List<TransactionModel>> getTodayTransactions() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    return getTransactionsByDateRange(start, end);
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Budget CRUD
  Future<int> setBudget(BudgetModel budget) async {
    final db = await database;
    // Remove existing budget for same category/month/year
    await db.delete(
      'budgets',
      where: 'category = ? AND month = ? AND year = ?',
      whereArgs: [budget.category, budget.month, budget.year],
    );
    return await db.insert('budgets', budget.toMap());
  }

  Future<BudgetModel?> getBudget(String category, int month, int year) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'category = ? AND month = ? AND year = ?',
      whereArgs: [category, month, year],
    );
    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  Future<List<BudgetModel>> getAllBudgets(int month, int year) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Stats
  Future<double> getTotalByMonth(int year, int month, TransactionType type) async {
    final db = await database;
    final typeVal = type == TransactionType.expense ? 0 : 1;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE '
      'type = ? AND strftime("%Y", date) = ? AND strftime("%m", date) = ?',
      [typeVal, year.toString().padLeft(4, '0'), month.toString().padLeft(2, '0')],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<Map<String, double>> getCategoryTotalsByMonth(int year, int month) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, COALESCE(SUM(amount), 0) as total FROM transactions WHERE '
      'type = 0 AND strftime("%Y", date) = ? AND strftime("%m", date) = ? '
      'GROUP BY category ORDER BY total DESC',
      [year.toString().padLeft(4, '0'), month.toString().padLeft(2, '0')],
    );
    final map = <String, double>{};
    for (final row in result) {
      map[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return map;
  }
}
