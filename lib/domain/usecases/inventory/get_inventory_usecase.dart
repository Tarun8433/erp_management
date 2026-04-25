import '../../entities/inventory_item.dart';
import '../../repositories/inventory_repository.dart';

class GetInventoryUseCase {
  final InventoryRepository repository;

  GetInventoryUseCase(this.repository);

  Future<List<InventoryItem>> call() => repository.getInventoryItems();
}
