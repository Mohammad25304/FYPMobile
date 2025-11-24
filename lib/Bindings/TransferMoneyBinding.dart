import 'package:get/get.dart';
import 'package:cashpilot/Controllers/TransferMoneyController.dart';

class TransferMoneyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferMoneyController>(() => TransferMoneyController());
  }
}
