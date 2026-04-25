import 'package:get/get.dart';

import '../../data/repositories/employee_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/usecases/employee/get_employees_usecase.dart';
import '../../domain/usecases/inventory/get_inventory_usecase.dart';
import '../../domain/usecases/finance/get_finances_usecase.dart';
import '../../presentation/viewmodels/dashboard_controller.dart';
import '../../presentation/viewmodels/employee_controller.dart';
import '../../presentation/viewmodels/inventory_controller.dart';
import '../../presentation/viewmodels/finance_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<EmployeeRepository>(() => EmployeeRepositoryImpl(), fenix: true);
    Get.lazyPut<InventoryRepository>(() => InventoryRepositoryImpl(), fenix: true);
    Get.lazyPut<FinanceRepository>(() => FinanceRepositoryImpl(), fenix: true);

    // Use cases
    Get.lazyPut(() => GetEmployeesUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetInventoryUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetFinancesUseCase(Get.find()), fenix: true);

    // Controllers (ViewModels)
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => EmployeeController(Get.find()), fenix: true);
    Get.lazyPut(() => InventoryController(Get.find()), fenix: true);
    Get.lazyPut(() => FinanceController(Get.find()), fenix: true);
  }
}
