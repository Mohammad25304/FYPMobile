import 'package:get/get.dart';
import 'package:cashpilot/Controllers/SettingsController.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SettingsController());
  }
}
