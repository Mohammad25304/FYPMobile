import 'package:get/get.dart';
import '../Controllers/HomeController.dart';
import '../Controllers/ServiceController.dart';

class ServiceBinding extends Bindings {
  @override
  void dependencies() {
    // 🔑 HomeController MUST exist before ServiceController
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController(), permanent: true);
    }

    // ServiceController for Services page
    Get.put<ServiceController>(ServiceController());
  }
}
