class CategoryModel {
  final int? id;
  final String? name;

  CategoryModel({this.id, this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['Id'] ?? json['categoryId'] ?? json['classId'] ?? json['groupId'],
      name: json['name'] ?? json['Name'] ?? json['categoryName'] ?? json['className'] ?? json['groupName'],
    );
  }
}
