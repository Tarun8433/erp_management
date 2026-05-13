import 'package:get/get.dart';
import '../services/api/api_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.put(AuthRepository(), permanent: true);
  }
}
