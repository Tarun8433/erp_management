import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class FinanceRecord extends Equatable {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String category;
  final String? notes;

  const FinanceRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    this.notes,
  });

  @override
  List<Object?> get props =>
      [id, title, amount, type, date, category, notes];
}
