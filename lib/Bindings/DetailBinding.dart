import 'package:get/get.dart';
import 'package:cashpilot/Controllers/DetailsController.dart';

class DetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DetailsController());
  }
}
