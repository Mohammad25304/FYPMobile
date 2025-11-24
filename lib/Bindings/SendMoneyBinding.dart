import 'package:get/get.dart';
import 'package:cashpilot/Controllers/SendMoneyController.dart';

class SendMoneyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SendMoneyController>(() => SendMoneyController());
  }
}
