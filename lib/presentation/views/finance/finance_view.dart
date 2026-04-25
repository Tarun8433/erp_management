import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../domain/entities/finance_record.dart';
import '../../viewmodels/finance_controller.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FinanceController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError.value) {
          return Center(child: Text(controller.errorMessage.value));
        }
        return Column(
          children: [
            _FinanceSummary(
              income: controller.totalIncome,
              expenses: controller.totalExpenses,
              balance: controller.netBalance,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.records.length,
                itemBuilder: (_, i) {
                  final record = controller.records[i];
                  final isIncome = record.type == TransactionType.income;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isIncome
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.error.withOpacity(0.15),
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? AppColors.success : AppColors.error,
                        ),
                      ),
                      title: Text(record.title),
                      subtitle: Text(
                          '${record.category} • ${AppUtils.formatDate(record.date)}'),
                      trailing: Text(
                        '${isIncome ? '+' : '-'}${AppUtils.formatCurrency(record.amount)}',
                        style: TextStyle(
                          color: isIncome ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _FinanceSummary extends StatelessWidget {
  final double income;
  final double expenses;
  final double balance;

  const _FinanceSummary({
    required this.income,
    required this.expenses,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Item(label: 'Income', value: income, color: Colors.greenAccent),
          _Item(label: 'Expenses', value: expenses, color: Colors.redAccent),
          _Item(label: 'Balance', value: balance, color: Colors.white),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _Item({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(AppUtils.formatCurrency(value),
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
