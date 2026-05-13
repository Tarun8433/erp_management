import 'package:get/get.dart';
import '../controllers/forget_mpin_controller.dart';

class ForgetMpinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgetMpinController>(
      () => ForgetMpinController(),
    );
  }
}
