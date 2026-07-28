import 'package:get/get.dart';
import '../services/api/api_service.dart';
import '../../features/common/auth/data/repositories/auth_repository.dart';
import '../../features/common/menu/controllers/menu_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.put(AuthRepository(), permanent: true);
    // MenuController is used across home, profile and role dashboards. Register
    // it app-wide (fenix recreates it after disposal) so Get.find always
    // resolves it instead of failing on routes that lack a local binding.
    Get.lazyPut<MenuController>(() => MenuController(), fenix: true);
  }
}
