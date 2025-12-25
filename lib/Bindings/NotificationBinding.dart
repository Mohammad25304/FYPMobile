import 'package:get/get.dart';
import '../Controllers/NotificationController.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NotificationController());
  }
}
