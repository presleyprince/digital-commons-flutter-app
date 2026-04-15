import 'package:digital_shores/core/enums.dart';

class FinanceLog {
  final String id;
  final int amount;
  final String description;
  final DateTime date;
  final FinanceLogCategory category;

  FinanceLog({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });

  FinanceLog copyWith({
    int? amount,
    String? description,
    DateTime? date,
    FinanceLogCategory? category,
  }) {
    return FinanceLog(
      id: id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}
