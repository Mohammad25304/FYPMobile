import 'package:get/get.dart';
import 'package:cashpilot/Controllers/ForgetPasswordController.dart';

class ForgetPasswordEmailBinding extends Bindings {
  @override
  void dependencies() {
    // Create the controller only once and reuse it
    if (!Get.isRegistered<ForgetPasswordController>()) {
      Get.put<ForgetPasswordController>(
        ForgetPasswordController(),
        permanent: true,
      );
    }
  }
}
