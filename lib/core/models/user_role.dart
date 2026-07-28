import '../../routes/app_routes.dart';

enum UserRole { principal, teacher, driver, parent, unknown }

extension UserRoleX on UserRole {
  static UserRole fromApi(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'principal':
      case 'admin':
      case 'branchadmin':
        return UserRole.principal;
      case 'teacher':
      case 'employee':
        return UserRole.teacher;
      case 'driver':
        return UserRole.driver;
      case 'parent':
        return UserRole.parent;
      default:
        return UserRole.principal;
    }
  }

  String get storageKey => name;

  String get initialRoute {
    switch (this) {
      case UserRole.principal:
        return AppRoutes.principalDashboard;
      case UserRole.teacher:
        return AppRoutes.teacherDashboard;
      case UserRole.driver:
        return AppRoutes.driverDashboard;
      case UserRole.parent:
        return AppRoutes.parentDashboard;
      case UserRole.unknown:
        return AppRoutes.auth;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.principal:
        return 'Principal';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.driver:
        return 'Driver';
      case UserRole.parent:
        return 'Parent';
      case UserRole.unknown:
        return 'User';
    }
  }
}
