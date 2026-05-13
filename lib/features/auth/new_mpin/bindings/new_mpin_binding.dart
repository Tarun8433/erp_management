import 'package:get/get.dart';
import '../controllers/new_mpin_controller.dart';

class NewMpinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewMpinController>(
      () => NewMpinController(),
    );
  }
}
