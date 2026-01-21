import 'package:cashpilot/Controllers/HomeController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:get/get.dart';
import '../Controllers/PayTelecomController.dart';

class PayTelecomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletController>(() => WalletController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<PayTelecomController>(() => PayTelecomController());
  }
}
