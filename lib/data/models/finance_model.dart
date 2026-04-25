import '../../domain/entities/finance_record.dart';

class FinanceModel extends FinanceRecord {
  const FinanceModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.date,
    required super.category,
    super.notes,
  });

  factory FinanceModel.fromJson(Map<String, dynamic> json) => FinanceModel(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        date: DateTime.parse(json['date'] as String),
        category: json['category'] as String,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'date': date.toIso8601String(),
        'category': category,
        'notes': notes,
      };

  factory FinanceModel.dummy(int index) => FinanceModel(
        id: 'fin_$index',
        title: ['Salary Payment', 'Office Rent', 'Equipment Sale', 'Utility Bill'][index % 4],
        amount: 1000.0 + index * 500,
        type: index % 2 == 0 ? TransactionType.income : TransactionType.expense,
        date: DateTime(2025, index % 12 + 1, index % 28 + 1),
        category: ['Payroll', 'Operations', 'Sales', 'Utilities'][index % 4],
      );
}
