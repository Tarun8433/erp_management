class AppRoutes {
  AppRoutes._();
  static const String dashboard = '/Dashboard';
  static const String home = '/home';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String signup = '/signup';
  static const String auth = '/auth';
  static const String verification = '/verification';
  static const String languageTheme = '/language-theme';
  static const String forgetPassword = '/forget-password';
  static const String forgetMpin = '/forget-mpin';
  static const String newPassword = '/new-password';
  static const String newMpin = '/new-mpin';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // CN Management
  static const String cnManagement = '/cn-management';

  // Role-specific dashboards
  static const String principalDashboard = '/dashboard/principal';
  static const String teacherDashboard = '/dashboard/teacher';
  static const String driverDashboard = '/dashboard/driver';
  static const String parentDashboard = '/dashboard/parent';
  static const String newAdmission = '/dashboard/principal/new-admission';
  static const String studentList = '/dashboard/principal/student-list';
  static const String newAdmissionReport =
      '/dashboard/principal/admission-report';
  static const String studentPromotion =
      '/dashboard/principal/student-promotion';
  static const String seasonUpdate = '/dashboard/principal/season-update';
  static const String addStudent = '/dashboard/principal/add-student';
}
