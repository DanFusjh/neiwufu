import 'dart:convert';

enum TransactionType { income, expense }

class TransactionModel {
  final int? id;
  final String category;
  final double amount;
  final TransactionType type;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.category,
    required this.amount,
    this.type = TransactionType.expense,
    this.note = '',
    DateTime? date,
    DateTime? createdAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'amount': amount,
        'type': type == TransactionType.expense ? 0 : 1,
        'note': note,
        'date': date.toIso8601String().split('T')[0],
        'created_at': createdAt.toIso8601String(),
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
      TransactionModel(
        id: map['id'] as int?,
        category: map['category'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] == 0 ? TransactionType.expense : TransactionType.income,
        note: map['note'] as String? ?? '',
        date: DateTime.parse(map['date'] as String),
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  TransactionModel copyWith({
    int? id,
    String? category,
    double? amount,
    TransactionType? type,
    String? note,
    DateTime? date,
  }) =>
      TransactionModel(
        id: id ?? this.id,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        note: note ?? this.note,
        date: date ?? this.date,
        createdAt: createdAt,
      );

  String toJson() => jsonEncode(toMap());

  factory TransactionModel.fromJson(String json) =>
      TransactionModel.fromMap(jsonDecode(json) as Map<String, dynamic>);
}

class BudgetModel {
  final int? id;
  final String category;
  final double limit;
  final int month;
  final int year;

  BudgetModel({
    this.id,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'limit': limit,
        'month': month,
        'year': year,
      };

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
        id: map['id'] as int?,
        category: map['category'] as String,
        limit: (map['limit'] as num).toDouble(),
        month: map['month'] as int,
        year: map['year'] as int,
      );

  BudgetModel copyWith({int? id, String? category, double? limit, int? month, int? year}) =>
      BudgetModel(
        id: id ?? this.id,
        category: category ?? this.category,
        limit: limit ?? this.limit,
        month: month ?? this.month,
        year: year ?? this.year,
      );
}
