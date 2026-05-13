import 'package:get/get.dart';

import '../controllers/cn_controller.dart';
import '../data/repositories/cn_repository.dart';

class CnBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CnRepository>(() => CnRepository());
    Get.lazyPut<CnController>(
      () => CnController(repository: Get.find<CnRepository>()),
    );
  }
}
