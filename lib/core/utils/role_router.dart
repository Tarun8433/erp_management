import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../models/user_role.dart';
import 'local_storage/storage_helper.dart';

class RoleRouter {
  RoleRouter._();

  static Future<UserRole> currentRole() async {
    final raw = await StorageHelper.getSelectedRole();
    return UserRoleX.fromApi(raw);
  }

  static Future<String> resolveLandingRoute() async {
    final role = await currentRole();
    return role.initialRoute;
  }

  static Future<void> goToLanding() async {
    final route = await resolveLandingRoute();
    Get.offAllNamed(route);
  }

  static Future<void> logout() async {
    await StorageHelper.clearUserData();
    Get.offAllNamed(AppRoutes.auth);
  }
}
