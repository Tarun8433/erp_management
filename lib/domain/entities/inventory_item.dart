import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int quantity;
  final double unitPrice;
  final int reorderLevel;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.reorderLevel,
  });

  bool get isLowStock => quantity <= reorderLevel;

  double get totalValue => quantity * unitPrice;

  @override
  List<Object?> get props =>
      [id, name, sku, category, quantity, unitPrice, reorderLevel];
}
