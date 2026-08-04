// import 'package:erp_management/features/role_based_ui/principal/fees/views/collect_fees_screen.dart';
// import 'package:erp_management/features/common/notifications/views/notifications_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/profile/views/principal_profile_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/attendance/views/attendance_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/attendance/views/attendance_marking_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/missing_images/views/missing_images_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/number_sheet/views/number_sheet_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/due_fees/views/due_fees_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/due_fees/bindings/due_fees_binding.dart';
// import 'package:erp_management/features/role_based_ui/principal/staff/views/staff_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/staff/bindings/staff_binding.dart';
// import 'package:erp_management/features/role_based_ui/principal/staff/views/staff_edit_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/staff/bindings/staff_form_binding.dart';
// import 'package:erp_management/features/role_based_ui/principal/admission/views/new_admission_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/admission_report/views/admission_report_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/student_promotion/views/student_promotion_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/season_update/bindings/season_update_binding.dart';
// import 'package:erp_management/features/role_based_ui/principal/season_update/views/season_update_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/new_student_list/views/student_list_screen.dart';
// import 'package:erp_management/features/role_based_ui/principal/add_student/bindings/add_student_binding.dart';
// import 'package:erp_management/features/role_based_ui/principal/add_student/views/add_student_screen.dart';
// import 'package:get/get.dart';
// import 'package:erp_management/features/common/home/widgets/nav_bar.dart';
// import 'app_routes.dart';
// import '../features/common/home/home_screen.dart';
// import '../features/common/home/home_binding.dart';
// import '../features/common/splash/views/splash_screen.dart';
// import '../features/common/splash/bindings/splash_binding.dart';
// import '../features/common/onboarding/views/onboarding_screen.dart';
// import '../features/common/onboarding/bindings/onboarding_binding.dart';
// import '../features/common/auth/signup/views/signup_screen.dart';
// import '../features/common/auth/signup/bindings/signup_binding.dart';
// import '../features/common/auth/views/auth_screen.dart';
// import '../features/common/auth/bindings/auth_binding.dart';
// import '../features/common/auth/biometric/views/biometric_unlock_screen.dart';
// import '../features/common/auth/verification/views/verification_screen.dart';
// import '../features/common/auth/verification/bindings/verification_binding.dart';
// import '../features/common/language_theme/views/language_theme_screen.dart';
// import '../features/common/language_theme/bindings/language_theme_binding.dart';
// import '../features/common/auth/forget_password/views/forget_password_screen.dart';
// import '../features/common/auth/forget_password/bindings/forget_password_binding.dart';
// import '../features/common/auth/forget_mpin/views/forget_mpin_screen.dart';
// import '../features/common/auth/forget_mpin/bindings/forget_mpin_binding.dart';
// import '../features/common/auth/new_password/views/new_password_screen.dart';
// import '../features/common/auth/new_password/bindings/new_password_binding.dart';
// import '../features/common/auth/new_mpin/views/new_mpin_screen.dart';
// import '../features/common/auth/new_mpin/bindings/new_mpin_binding.dart';
// import '../features/common/settings/setting_screen.dart';
// import '../features/common/settings/setting_binding.dart';
// import '../features/common/web_view/views/web_view_screen.dart';
// import '../features/common/help_support/views/help_support_screen.dart';
// import '../features/common/profile/views/profile_screen.dart';
// import '../features/common/profile/bindings/profile_binding.dart';
// import '../features/role_based_ui/principal/home/views/principal_dashboard_screen.dart';
// import '../features/role_based_ui/principal/home/bindings/principal_dashboard_binding.dart';
// import '../features/role_based_ui/teacher/views/teacher_dashboard_screen.dart';
// import '../features/role_based_ui/teacher/bindings/teacher_dashboard_binding.dart';
// import '../features/role_based_ui/driver/views/driver_dashboard_screen.dart';
// import '../features/role_based_ui/driver/bindings/driver_dashboard_binding.dart';
// import '../features/role_based_ui/parent/views/parent_dashboard_screen.dart';
// import '../features/role_based_ui/parent/bindings/parent_dashboard_binding.dart';
// import '../features/role_based_ui/parent/views/parent_profile_screen.dart';
// import '../features/role_based_ui/parent/attendance/views/parent_attendance_screen.dart';
// import '../features/role_based_ui/parent/fee/views/parent_fee_screen.dart';
// import '../features/role_based_ui/parent/timetable/views/parent_timetable_screen.dart';
// import '../features/role_based_ui/parent/result/views/parent_result_screen.dart';

// class AppPages {
//   AppPages._();

//   static const initial = AppRoutes.splash;

//   static final routes = [
//     GetPage(
//       name: AppRoutes.dashboard,
//       page: () => const NavBar(),
//       binding: HomeBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.home,
//       page: () => const HomeScreen(),
//       binding: HomeBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.splash,
//       page: () => const SplashScreen(),
//       binding: SplashBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.onboarding,
//       page: () => const OnboardingScreen(),
//       binding: OnboardingBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.signup,
//       page: () => const SignUpScreen(),
//       binding: SignUpBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.auth,
//       page: () => const AuthScreen(),
//       binding: AuthBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.biometricUnlock,
//       page: () => const BiometricUnlockScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.verification,
//       page: () => const VerificationScreen(),
//       binding: VerificationBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.languageTheme,
//       page: () => const LanguageThemeScreen(),
//       binding: LanguageThemeBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.forgetPassword,
//       page: () => const ForgetPasswordScreen(),
//       binding: ForgetPasswordBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.forgetMpin,
//       page: () => const ForgetMpinScreen(),
//       binding: ForgetMpinBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.newPassword,
//       page: () => const NewPasswordScreen(),
//       binding: NewPasswordBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.newMpin,
//       page: () => const NewMpinScreen(),
//       binding: NewMpinBinding(),
//     ),

//     GetPage(
//       name: AppRoutes.settings,
//       page: () => const SettingScreen(),
//       binding: SettingBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.profile,
//       page: () => const ProfileScreen(),
//       binding: ProfileBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.principalDashboard,
//       page: () => const PrincipalDashboardScreen(),
//       binding: PrincipalDashboardBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.teacherDashboard,
//       page: () => const TeacherDashboardScreen(),
//       binding: TeacherDashboardBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.driverDashboard,
//       page: () => const DriverDashboardScreen(),
//       binding: DriverDashboardBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.parentDashboard,
//       page: () => const ParentDashboardScreen(),
//       binding: ParentDashboardBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.parentProfile,
//       page: () => const ParentProfileScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.parentAttendance,
//       page: () => const ParentAttendanceScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.parentFee,
//       page: () => const ParentFeeScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.parentTimetable,
//       page: () => const ParentTimetableScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.parentResult,
//       page: () => const ParentResultScreen(),
//     ),

//     GetPage(
//       name: AppRoutes.newAdmission,
//       page: () => const NewAdmissionScreen(),
//     ),
//     GetPage(name: AppRoutes.studentList, page: () => const StudentListScreen()),
//     GetPage(name: AppRoutes.newAdmissionReport, page: () => const AdmissionReportScreen()),
//     GetPage(name: AppRoutes.studentPromotion, page: () => const StudentPromotionScreen()),
//     GetPage(
//       name: AppRoutes.seasonUpdate,
//       page: () => const SeasonUpdateScreen(),
//       binding: SeasonUpdateBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.addStudent,
//       page: () => const AddStudentScreen(),
//       binding: AddStudentBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.missingImages,
//       page: () => const MissingImagesScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.numberSheet,
//       page: () => const NumberSheetScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.dueFees,
//       page: () => const DueFeesScreen(),
//       binding: DueFeesBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.staff,
//       page: () => const StaffScreen(),
//       binding: StaffBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.staffEdit,
//       page: () => const StaffEditScreen(),
//       binding: StaffFormBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.notifications,
//       page: () => const NotificationsScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.attendance,
//       page: () => const AttendanceScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.attendanceMarking,
//       page: () => const AttendanceMarkingScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.principalProfile,
//       page: () => const PrincipalProfileScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.collectFees,
//       page: () => const CollectFeesScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.webView,
//       page: () => const WebViewScreen(),
//     ),
//     GetPage(
//       name: AppRoutes.helpSupport,
//       page: () => const HelpSupportScreen(),
//     ),
//   ];
// }
import 'package:erp_management/features/role_based_ui/principal/fees/views/collect_fees_screen.dart';
import 'package:erp_management/features/common/notifications/views/notifications_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/profile/views/principal_profile_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/attendance/views/attendance_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/missing_images/views/missing_images_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/number_sheet/views/number_sheet_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/due_fees/views/due_fees_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/due_fees/bindings/due_fees_binding.dart';
import 'package:erp_management/features/role_based_ui/principal/staff/views/staff_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/staff/bindings/staff_binding.dart';
import 'package:erp_management/features/role_based_ui/principal/staff/views/staff_edit_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/staff/bindings/staff_form_binding.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/views/new_admission_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/admission_report/views/admission_report_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/student_promotion/views/student_promotion_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/season_update/bindings/season_update_binding.dart';
import 'package:erp_management/features/role_based_ui/principal/season_update/views/season_update_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/views/student_list_screen.dart';
import 'package:erp_management/features/role_based_ui/principal/add_student/bindings/add_student_binding.dart';
import 'package:erp_management/features/role_based_ui/principal/add_student/views/add_student_screen.dart';
import 'package:get/get.dart';
import 'package:erp_management/features/common/home/widgets/nav_bar.dart';
import 'app_routes.dart';
import '../features/common/home/home_screen.dart';
import '../features/common/home/home_binding.dart';
import '../features/common/splash/views/splash_screen.dart';
import '../features/common/splash/bindings/splash_binding.dart';
import '../features/common/onboarding/views/onboarding_screen.dart';
import '../features/common/onboarding/bindings/onboarding_binding.dart';
import '../features/common/auth/signup/views/signup_screen.dart';
import '../features/common/auth/signup/bindings/signup_binding.dart';
import '../features/common/auth/views/auth_screen.dart';
import '../features/common/auth/bindings/auth_binding.dart';
import '../features/common/auth/biometric/views/biometric_unlock_screen.dart';
import '../features/common/auth/verification/views/verification_screen.dart';
import '../features/common/auth/verification/bindings/verification_binding.dart';
import '../features/common/language_theme/views/language_theme_screen.dart';
import '../features/common/language_theme/bindings/language_theme_binding.dart';
import '../features/common/auth/forget_password/views/forget_password_screen.dart';
import '../features/common/auth/forget_password/bindings/forget_password_binding.dart';
import '../features/common/auth/forget_mpin/views/forget_mpin_screen.dart';
import '../features/common/auth/forget_mpin/bindings/forget_mpin_binding.dart';
import '../features/common/auth/new_password/views/new_password_screen.dart';
import '../features/common/auth/new_password/bindings/new_password_binding.dart';
import '../features/common/auth/new_mpin/views/new_mpin_screen.dart';
import '../features/common/auth/new_mpin/bindings/new_mpin_binding.dart';
import '../features/common/settings/setting_screen.dart';
import '../features/common/settings/setting_binding.dart';
import '../features/common/web_view/views/web_view_screen.dart';
import '../features/common/help_support/views/help_support_screen.dart';
import '../features/common/profile/views/profile_screen.dart';
import '../features/common/profile/bindings/profile_binding.dart';
import '../features/role_based_ui/principal/home/views/principal_dashboard_screen.dart';
import '../features/role_based_ui/principal/home/bindings/principal_dashboard_binding.dart';
import '../features/role_based_ui/teacher/views/teacher_dashboard_screen.dart';
import '../features/role_based_ui/teacher/bindings/teacher_dashboard_binding.dart';
import '../features/role_based_ui/driver/views/driver_dashboard_screen.dart';
import '../features/role_based_ui/driver/bindings/driver_dashboard_binding.dart';
import '../features/role_based_ui/parent/views/parent_dashboard_screen.dart';
import '../features/role_based_ui/parent/bindings/parent_dashboard_binding.dart';
import '../features/role_based_ui/parent/views/parent_profile_screen.dart';
import '../features/role_based_ui/parent/attendance/views/parent_attendance_screen.dart';
import '../features/role_based_ui/parent/fee/views/parent_fee_screen.dart';
import '../features/role_based_ui/parent/timetable/views/parent_timetable_screen.dart';
import '../features/role_based_ui/parent/result/views/parent_result_screen.dart';

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
      name: AppRoutes.biometricUnlock,
      page: () => const BiometricUnlockScreen(),
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
      name: AppRoutes.parentProfile,
      page: () => const ParentProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.parentAttendance,
      page: () => const ParentAttendanceScreen(),
    ),
    GetPage(name: AppRoutes.parentFee, page: () => const ParentFeeScreen()),
    GetPage(
      name: AppRoutes.parentTimetable,
      page: () => const ParentTimetableScreen(),
    ),
    GetPage(
      name: AppRoutes.parentResult,
      page: () => const ParentResultScreen(),
    ),

    GetPage(
      name: AppRoutes.newAdmission,
      page: () => const NewAdmissionScreen(),
    ),
    GetPage(name: AppRoutes.studentList, page: () => const StudentListScreen()),
    GetPage(
      name: AppRoutes.newAdmissionReport,
      page: () => const AdmissionReportScreen(),
    ),
    GetPage(
      name: AppRoutes.studentPromotion,
      page: () => const StudentPromotionScreen(),
    ),
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
    GetPage(
      name: AppRoutes.missingImages,
      page: () => const MissingImagesScreen(),
    ),
    GetPage(name: AppRoutes.numberSheet, page: () => const NumberSheetScreen()),
    GetPage(
      name: AppRoutes.dueFees,
      page: () => const DueFeesScreen(),
      binding: DueFeesBinding(),
    ),
    GetPage(
      name: AppRoutes.staff,
      page: () => const StaffScreen(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.staffEdit,
      page: () => const StaffEditScreen(),
      binding: StaffFormBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
    ),
    GetPage(name: AppRoutes.attendance, page: () => const AttendanceScreen()),
    GetPage(
      name: AppRoutes.principalProfile,
      page: () => const PrincipalProfileScreen(),
    ),
    GetPage(name: AppRoutes.collectFees, page: () => const CollectFeesScreen()),
    GetPage(name: AppRoutes.webView, page: () => const WebViewScreen()),
    GetPage(name: AppRoutes.helpSupport, page: () => const HelpSupportScreen()),
  ];
}
