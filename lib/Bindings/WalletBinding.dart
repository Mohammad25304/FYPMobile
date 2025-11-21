import 'package:get/get.dart';
import 'package:cashpilot/Controllers/WalletController.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletController());
  }
}
