import '../../domain/entities/inventory_item.dart';

class InventoryModel extends InventoryItem {
  const InventoryModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.category,
    required super.quantity,
    required super.unitPrice,
    required super.reorderLevel,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) => InventoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        sku: json['sku'] as String,
        category: json['category'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unit_price'] as num).toDouble(),
        reorderLevel: json['reorder_level'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'category': category,
        'quantity': quantity,
        'unit_price': unitPrice,
        'reorder_level': reorderLevel,
      };

  factory InventoryModel.dummy(int index) => InventoryModel(
        id: 'inv_$index',
        name: ['Laptop', 'Monitor', 'Keyboard', 'Mouse', 'Headset'][index % 5],
        sku: 'SKU-${1000 + index}',
        category: ['Electronics', 'Accessories', 'Office'][index % 3],
        quantity: 10 + index * 3,
        unitPrice: 100.0 + index * 50,
        reorderLevel: 5,
      );
}
