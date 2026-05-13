import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../core/models/user_role.dart';
import '../../../core/utils/local_storage/storage_helper.dart';
import '../../../core/utils/role_router.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    final isIntroSeen = await StorageHelper.isIntroSeen();
    if (!isIntroSeen) {
      Get.offNamed(AppRoutes.languageTheme);
      return;
    }

    final isLoggedIn = await StorageHelper.getLoginStatus();
    if (!isLoggedIn) {
      Get.offNamed(AppRoutes.auth);
      return;
    }

    final token = await StorageHelper.getToken();
    final exp = await StorageHelper.getTokenExpiry();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (token == null || token.isEmpty || exp == null || now >= exp) {
      await StorageHelper.clearUserData();
      Get.offNamed(AppRoutes.auth);
      return;
    }

    // Logged in with a valid token — route to the role-specific dashboard.
    // If role is unknown/unrecognized, fall back to auth (covers legacy storage).
    final role = await RoleRouter.currentRole();
    if (role == UserRole.unknown) {
      Get.offNamed(AppRoutes.auth, arguments: {'unlock': true});
      return;
    }

    final biometricEnabled = await StorageHelper.getBiometricEnabled();
    if (biometricEnabled) {
      Get.offNamed(AppRoutes.auth, arguments: {'unlock': true});
      return;
    }

    Get.offAllNamed(role.initialRoute);
  }
}
