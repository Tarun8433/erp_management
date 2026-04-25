import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.name,
    required super.email,
    required super.department,
    required super.position,
    required super.salary,
    required super.joinDate,
    super.isActive,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        department: json['department'] as String,
        position: json['position'] as String,
        salary: (json['salary'] as num).toDouble(),
        joinDate: DateTime.parse(json['join_date'] as String),
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'department': department,
        'position': position,
        'salary': salary,
        'join_date': joinDate.toIso8601String(),
        'is_active': isActive,
      };

  factory EmployeeModel.dummy(int index) => EmployeeModel(
        id: 'emp_$index',
        name: ['Alice Johnson', 'Bob Smith', 'Carol White', 'David Brown'][index % 4],
        email: 'employee$index@erp.com',
        department: ['Engineering', 'Finance', 'HR', 'Sales'][index % 4],
        position: ['Manager', 'Developer', 'Analyst', 'Executive'][index % 4],
        salary: 50000 + (index * 5000).toDouble(),
        joinDate: DateTime(2020 + index % 4, index % 12 + 1, 1),
      );
}
