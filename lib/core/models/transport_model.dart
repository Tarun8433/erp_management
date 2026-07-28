class VehicleModel {
  final int id;
  final String name;
  final String number;

  VehicleModel({required this.id, required this.name, required this.number});

  String get displayLabel => number.isNotEmpty ? '$name ($number)' : name;

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
        number: json['number']?.toString() ?? '',
      );
}

class RouteModel {
  final int id;
  final String fullName;

  RouteModel({required this.id, required this.fullName});

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      );
}

class PickupPointModel {
  final int id;
  final String name;

  PickupPointModel({required this.id, required this.name});

  factory PickupPointModel.fromJson(Map<String, dynamic> json) => PickupPointModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
      );
}
