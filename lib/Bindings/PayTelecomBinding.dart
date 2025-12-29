import 'package:get/get.dart';
import '../Controllers/PayTelecomController.dart';

class PayTelecomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PayTelecomController>(() => PayTelecomController());
  }
}
