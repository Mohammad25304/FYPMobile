import 'package:get/get.dart';
import 'package:cashpilot/Controllers/HelpCenterController.dart';

class HelpCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HelpCenterController());
  }
}
