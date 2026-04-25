import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../viewmodels/employee_controller.dart';

class EmployeeListView extends StatelessWidget {
  const EmployeeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmployeeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadEmployees,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: controller.search,
              decoration: InputDecoration(
                hintText: 'Search by name or department...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.hasError.value) {
                return Center(child: Text(controller.errorMessage.value));
              }
              final list = controller.filteredEmployees;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final emp = list[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          AppUtils.getInitials(emp.name),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(emp.name),
                      subtitle: Text('${emp.department} • ${emp.position}'),
                      trailing: Text(
                        AppUtils.formatCurrency(emp.salary),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.snackbar('Add Employee', 'Coming soon!'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
