import 'package:get/get.dart';
import 'package:cashpilot/Controllers/SendMoneyController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';

class SendMoneyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletController>(() => WalletController());
    Get.lazyPut<SendMoneyController>(() => SendMoneyController());
  }
}
