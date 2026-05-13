import 'package:get/get.dart';
import '../controllers/language_theme_controller.dart';

class LanguageThemeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageThemeController>(() => LanguageThemeController());
  }
}
