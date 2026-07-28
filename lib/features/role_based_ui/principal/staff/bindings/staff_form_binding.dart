import 'package:get/get.dart';
import '../controllers/staff_form_controller.dart';

class StaffFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffFormController>(() => StaffFormController());
  }
}
