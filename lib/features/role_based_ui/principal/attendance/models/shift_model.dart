class ShiftModel {
  final int id;
  final String name;

  const ShiftModel({required this.id, required this.name});

  factory ShiftModel.fromJson(Map<String, dynamic> json) => ShiftModel(
        id: (json['id'] ?? json['Id'] ?? 0) as int,
        name: (json['name'] ?? json['Name'] ?? '').toString(),
      );
}
