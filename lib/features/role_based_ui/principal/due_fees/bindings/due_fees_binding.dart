import 'package:get/get.dart';
import '../controllers/due_fees_controller.dart';

class DueFeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DueFeesController>(() => DueFeesController());
  }
}
