import 'package:get/get.dart';
import 'package:cashpilot/Controllers/TermsController.dart';

class TermsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TermsController());
  }
}
