import 'package:get/get.dart';
 import '../profile/controllers/profile_controller.dart';
import '../menu/controllers/menu_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
     Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MenuController>(() => MenuController());
  }
}
