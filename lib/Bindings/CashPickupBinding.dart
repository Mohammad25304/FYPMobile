import 'package:get/get.dart';
import 'package:cashpilot/Controllers/CashPickupController.dart';

class CashPickupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashPickupController>(() => CashPickupController());
  }
}
