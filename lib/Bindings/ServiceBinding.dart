import 'package:get/get.dart';
import '../Controllers/HomeController.dart';
import '../Controllers/ServiceController.dart';

class ServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ServiceController>(ServiceController(), permanent: true);
  }
}
