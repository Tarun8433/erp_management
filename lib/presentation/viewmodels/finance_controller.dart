import 'package:get/get.dart';

import '../../domain/entities/finance_record.dart';
import '../../domain/usecases/finance/get_finances_usecase.dart';

class FinanceController extends GetxController {
  final GetFinancesUseCase _getFinancesUseCase;

  FinanceController(this._getFinancesUseCase);

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final records = <FinanceRecord>[].obs;

  double get totalIncome => records
      .where((r) => r.type == TransactionType.income)
      .fold(0, (sum, r) => sum + r.amount);

  double get totalExpenses => records
      .where((r) => r.type == TransactionType.expense)
      .fold(0, (sum, r) => sum + r.amount);

  double get netBalance => totalIncome - totalExpenses;

  @override
  void onInit() {
    super.onInit();
    loadFinances();
  }

  Future<void> loadFinances() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      records.value = await _getFinancesUseCase();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load finances: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
