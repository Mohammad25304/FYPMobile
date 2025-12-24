import 'package:get/get.dart';
import 'package:cashpilot/Controllers/MonthlyStatsController.dart';

class MonthlyStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MonthlyStatsController>(
      () => MonthlyStatsController(),
      fenix: true,
    );
  }
}
