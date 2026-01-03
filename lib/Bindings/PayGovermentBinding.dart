import 'package:cashpilot/Controllers/PayGovermentController.dart';
import 'package:get/get.dart';

class PayGovernmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PayGovernmentController());
  }
}
