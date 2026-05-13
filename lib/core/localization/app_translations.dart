import 'package:get/get.dart';
import 'translations/en_us.dart';
import 'translations/hi_in.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en': enUs, 'hi': hiIn};
}
