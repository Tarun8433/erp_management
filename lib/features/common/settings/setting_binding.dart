import 'package:get/get.dart';
import 'setting_controller.dart';
import '../language_theme/controllers/language_theme_controller.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingController>(() => SettingController());
    Get.lazyPut<LanguageThemeController>(() => LanguageThemeController());
  }
}
