import 'package:get/get.dart';

class DashboardStats {
  final int totalEmployees;
  final int totalInventoryItems;
  final double totalRevenue;
  final double totalExpenses;

  const DashboardStats({
    required this.totalEmployees,
    required this.totalInventoryItems,
    required this.totalRevenue,
    required this.totalExpenses,
  });

  double get netProfit => totalRevenue - totalExpenses;
}

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final stats = Rxn<DashboardStats>();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      stats.value = const DashboardStats(
        totalEmployees: 10,
        totalInventoryItems: 12,
        totalRevenue: 150000,
        totalExpenses: 85000,
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load dashboard: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
