import 'package:get/get.dart';
import 'package:cashpilot/Controllers/AddMoneyController.dart';

class AddMoneyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMoneyController>(() => AddMoneyController());
  }
}
