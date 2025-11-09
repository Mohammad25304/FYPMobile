import 'package:get/get.dart';
import 'package:cashpilot/Controllers/RegistrationController.dart';

class RegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(() => RegistrationController());
  }
}