import 'package:get/get.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/inventory/get_inventory_usecase.dart';

class InventoryController extends GetxController {
  final GetInventoryUseCase _getInventoryUseCase;

  InventoryController(this._getInventoryUseCase);

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final items = <InventoryItem>[].obs;

  List<InventoryItem> get lowStockItems => items.where((i) => i.isLowStock).toList();
  double get totalValue => items.fold(0, (sum, i) => sum + i.totalValue);

  @override
  void onInit() {
    super.onInit();
    loadInventory();
  }

  Future<void> loadInventory() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      items.value = await _getInventoryUseCase();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load inventory: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
