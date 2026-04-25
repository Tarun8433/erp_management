import 'package:get/get.dart';

import '../../presentation/views/dashboard/dashboard_view.dart';
import '../../presentation/views/employees/employee_list_view.dart';
import '../../presentation/views/inventory/inventory_view.dart';
import '../../presentation/views/finance/finance_view.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String employees = '/employees';
  static const String inventory = '/inventory';
  static const String finance = '/finance';

  static final pages = [
    GetPage(name: dashboard, page: () => const DashboardView()),
    GetPage(name: employees, page: () => const EmployeeListView()),
    GetPage(name: inventory, page: () => const InventoryView()),
    GetPage(name: finance, page: () => const FinanceView()),
  ];
}
