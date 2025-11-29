import 'package:get/get.dart';
import 'package:cashpilot/Controllers/ForgetPasswordController.dart';

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    // Reuse the existing instance - don't create a new one
    if (!Get.isRegistered<ForgetPasswordController>()) {
      Get.put<ForgetPasswordController>(
        ForgetPasswordController(),
        permanent: true,
      );
    }
  }
}
