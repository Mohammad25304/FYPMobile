import 'package:get/get.dart';
import 'package:cashpilot/Controllers/PrivacyController.dart';

class PrivacyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PrivacyController());
  }
}
