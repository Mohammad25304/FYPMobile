import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class PaymentController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  RxBool isLoading = false.obs;

  RxList<dynamic> allPayments = <dynamic>[].obs;
  RxList<dynamic> payments = <dynamic>[].obs;

  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxString selectedRangeType = 'day'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      isLoading.value = true;

      final response = await _dio.get("payments");
      allPayments.assignAll(response.data["payments"] ?? []);

      applyFilter();
    } catch (_) {
      Get.snackbar("Error", "Failed to load payments");
    } finally {
      isLoading.value = false;
    }
  }

  void changeSelectedDate(DateTime date) {
    selectedDate.value = date;
    applyFilter();
  }

  void changeRangeType(String type) {
    selectedRangeType.value = type;
    applyFilter();
  }

  void applyFilter() {
    if (allPayments.isEmpty) {
      payments.clear();
      return;
    }

    final base = selectedDate.value;
    late DateTime start;
    late DateTime end;

    switch (selectedRangeType.value) {
      case 'week':
        start = base.subtract(Duration(days: base.weekday - 1));
        end = start.add(const Duration(days: 7));
        break;
      case 'month':
        start = DateTime(base.year, base.month, 1);
        end = DateTime(base.year, base.month + 1, 1);
        break;
      case 'year':
        start = DateTime(base.year, 1, 1);
        end = DateTime(base.year + 1, 1, 1);
        break;
      default:
        start = DateTime(base.year, base.month, base.day);
        end = start.add(const Duration(days: 1));
    }

    final filtered = allPayments.where((p) {
      final rawDate = p["transacted_at"];
      if (rawDate == null) return true; // ✅ never discard

      try {
        final dt = DateTime.parse(rawDate);
        return !dt.isBefore(start) && dt.isBefore(end); // ✅ inclusive start
      } catch (_) {
        return true;
      }
    }).toList();

    payments.assignAll(filtered);
  }
}
