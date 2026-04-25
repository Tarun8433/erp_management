import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  @override
  Future<List<Employee>> getEmployees() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(10, (i) => EmployeeModel.dummy(i));
  }

  @override
  Future<Employee?> getEmployeeById(String id) async {
    final employees = await getEmployees();
    try {
      return employees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addEmployee(Employee employee) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> updateEmployee(Employee employee) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> deleteEmployee(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
