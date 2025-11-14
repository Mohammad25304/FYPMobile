import 'package:cashpilot/Controllers/OtpVerificationController.dart';
import 'package:get/get.dart';

class OtpVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpVerificationController>(() => OtpVerificationController());
  }
}
