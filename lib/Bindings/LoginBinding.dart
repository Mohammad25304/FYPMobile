import 'package:cashpilot/Controllers/LoginController.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(
      LoginController(),
      permanent: true, // ✅ Keep it alive forever
    );
  }
}
