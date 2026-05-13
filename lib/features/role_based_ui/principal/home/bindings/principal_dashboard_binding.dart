import 'package:get/get.dart';
import '../controllers/principal_dashboard_controller.dart';

class PrincipalDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrincipalDashboardController>(
      () => PrincipalDashboardController(),
    );
  }
}
