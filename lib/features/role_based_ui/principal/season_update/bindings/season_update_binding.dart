import 'package:get/get.dart';
import '../controllers/season_update_controller.dart';

class SeasonUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SeasonUpdateController>(() => SeasonUpdateController());
  }
}
