import 'package:cashpilot/Controllers/PayInternetController.dart';
import 'package:get/get.dart';

class PayInternetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PayInternetController());
  }
}
