import 'package:get/get.dart';
import 'package:cashpilot/Controllers/AddMoneyController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';

class AddMoneyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletController>(() => WalletController());
    Get.lazyPut<AddMoneyController>(() => AddMoneyController());
  }
}
