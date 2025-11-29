import 'package:get/get.dart';
import 'package:cashpilot/Controllers/ForgetPasswordController.dart';

class ForgetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ForgetPasswordController>(
      ForgetPasswordController(),
      permanent: true,
    );
  }
}
