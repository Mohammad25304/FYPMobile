import 'package:cashpilot/Controllers/ServiceController.dart';
import 'package:get/get.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ServiceController>(ServiceController());
  }
}
