import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(12, (i) => InventoryModel.dummy(i));
  }

  @override
  Future<InventoryItem?> getItemById(String id) async {
    final items = await getInventoryItems();
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addItem(InventoryItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> deleteItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
