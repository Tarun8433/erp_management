import 'package:get/get.dart';
import '../profile/controllers/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
    // MenuController is registered app-wide in InitialBinding.
  }
}
