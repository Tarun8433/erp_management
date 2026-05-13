import 'package:erp_management/features/cn_management/views/cn_management_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/views/new_admission_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/admission_report/views/admission_report_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/student_promotion/views/student_promotion_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/season_update/bindings/season_update_binding.dart';
import 'package:erp_management/features/role_based_ui/principal/season_update/views/season_update_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/views/student_list_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/add_student/bindings/add_student_binding.dart';
import 'package:erp_management/features/role_based_ui/principal/add_student/views/add_student_screen.dart';
import 'package:get/get.dart';
import 'package:erp_management/features/home/widgets/nav_bar.dart';
import 'app_routes.dart';
import '../features/home/home_screen.dart';
import '../features/home/home_binding.dart';
import '../features/splash/views/splash_screen.dart';
import '../features/splash/bindings/splash_binding.dart';
import '../features/onboarding/views/onboarding_screen.dart';
import '../features/onboarding/bindings/onboarding_binding.dart';
import '../features/auth/signup/views/signup_screen.dart';
import '../features/auth/signup/bindings/signup_binding.dart';
import '../features/auth/views/auth_screen.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/verification/views/verification_screen.dart';
import '../features/auth/verification/bindings/verification_binding.dart';
import '../features/language_theme/views/language_theme_screen.dart';
import '../features/language_theme/bindings/language_theme_binding.dart';
import '../features/auth/forget_password/views/forget_password_screen.dart';
import '../features/auth/forget_password/bindings/forget_password_binding.dart';
import '../features/auth/forget_mpin/views/forget_mpin_screen.dart';
import '../features/auth/forget_mpin/bindings/forget_mpin_binding.dart';
import '../features/auth/new_password/views/new_password_screen.dart';
import '../features/auth/new_password/bindings/new_password_binding.dart';
import '../features/auth/new_mpin/views/new_mpin_screen.dart';
import '../features/auth/new_mpin/bindings/new_mpin_binding.dart';
import '../features/settings/setting_screen.dart';
import '../features/settings/setting_binding.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/profile/bindings/profile_binding.dart';
import '../features/role_based_ui/principal/home/views/principal_dashboard_screen.dart';
import '../features/role_based_ui/principal/home/bindings/principal_dashboard_binding.dart';
import '../features/role_based_ui/teacher/views/teacher_dashboard_screen.dart';
import '../features/role_based_ui/teacher/bindings/teacher_dashboard_binding.dart';
import '../features/role_based_ui/driver/views/driver_dashboard_screen.dart';
import '../features/role_based_ui/driver/bindings/driver_dashboard_binding.dart';
import '../features/role_based_ui/parent/views/parent_dashboard_screen.dart';
import '../features/role_based_ui/parent/bindings/parent_dashboard_binding.dart';
import '../features/cn_management/bindings/cn_binding.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const NavBar(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignUpScreen(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationScreen(),
      binding: VerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.languageTheme,
      page: () => const LanguageThemeScreen(),
      binding: LanguageThemeBinding(),
    ),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => const ForgetPasswordScreen(),
      binding: ForgetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.forgetMpin,
      page: () => const ForgetMpinScreen(),
      binding: ForgetMpinBinding(),
    ),
    GetPage(
      name: AppRoutes.newPassword,
      page: () => const NewPasswordScreen(),
      binding: NewPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.newMpin,
      page: () => const NewMpinScreen(),
      binding: NewMpinBinding(),
    ),

    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingScreen(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.principalDashboard,
      page: () => const PrincipalDashboardScreen(),
      binding: PrincipalDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherDashboard,
      page: () => const TeacherDashboardScreen(),
      binding: TeacherDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.driverDashboard,
      page: () => const DriverDashboardScreen(),
      binding: DriverDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.parentDashboard,
      page: () => const ParentDashboardScreen(),
      binding: ParentDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.cnManagement,
      page: () => const CnManagementScreen(),
      binding: CnBinding(),
    ),
    GetPage(
      name: AppRoutes.newAdmission,
      page: () => const NewAdmissionScreen(),
    ),
    GetPage(name: AppRoutes.studentList, page: () => const StudentListScreen()),
    GetPage(name: AppRoutes.newAdmissionReport, page: () => const AdmissionReportScreen()),
    GetPage(name: AppRoutes.studentPromotion, page: () => const StudentPromotionScreen()),
    GetPage(
      name: AppRoutes.seasonUpdate,
      page: () => const SeasonUpdateScreen(),
      binding: SeasonUpdateBinding(),
    ),
    GetPage(
      name: AppRoutes.addStudent,
      page: () => const AddStudentScreen(),
      binding: AddStudentBinding(),
    ),
  ];
}
