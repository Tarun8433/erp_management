import 'package:get/get.dart';

import '../../domain/entities/employee.dart';
import '../../domain/usecases/employee/get_employees_usecase.dart';

class EmployeeController extends GetxController {
  final GetEmployeesUseCase _getEmployeesUseCase;

  EmployeeController(this._getEmployeesUseCase);

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final employees = <Employee>[].obs;
  final searchQuery = ''.obs;

  List<Employee> get filteredEmployees => searchQuery.value.isEmpty
      ? employees
      : employees.where((e) =>
          e.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          e.department.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
  }

  void search(String query) => searchQuery.value = query;

  Future<void> loadEmployees() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      employees.value = await _getEmployeesUseCase();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load employees: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
