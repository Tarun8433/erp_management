import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final double salary;
  final DateTime joinDate;
  final bool isActive;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.salary,
    required this.joinDate,
    this.isActive = true,
  });

  @override
  List<Object?> get props =>
      [id, name, email, department, position, salary, joinDate, isActive];
}
