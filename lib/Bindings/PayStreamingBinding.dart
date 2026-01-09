import 'package:cashpilot/Controllers/PayStreamingController.dart';
import 'package:get/get.dart';

class PayStreamingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PayStreamingController>(() => PayStreamingController());
  }
}
