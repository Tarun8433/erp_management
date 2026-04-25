import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../viewmodels/inventory_controller.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError.value) {
          return Center(child: Text(controller.errorMessage.value));
        }
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Value',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    AppUtils.formatCurrency(controller.totalValue),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.items.length,
                itemBuilder: (_, i) {
                  final item = controller.items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('SKU: ${item.sku} • ${item.category}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Qty: ${item.quantity}',
                              style: TextStyle(
                                  color: item.isLowStock
                                      ? AppColors.error
                                      : AppColors.success,
                                  fontWeight: FontWeight.bold)),
                          Text(AppUtils.formatCurrency(item.unitPrice),
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      leading: item.isLowStock
                          ? const Icon(Icons.warning, color: AppColors.warning)
                          : const Icon(Icons.inventory_2,
                              color: AppColors.primary),
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
