import 'package:get/get.dart';
import 'package:cashpilot/Controllers/ContactInfoController.dart';

class ContactInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContactInfoController>(
      () => ContactInfoController(),
      fenix: true,
    );
  }
}
