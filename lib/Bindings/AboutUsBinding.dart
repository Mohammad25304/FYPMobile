// Bindings/AboutUsBinding.dart
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/AboutUsController.dart';

class AboutUsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AboutUsController());
  }
}
