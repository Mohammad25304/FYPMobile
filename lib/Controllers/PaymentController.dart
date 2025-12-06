import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class PaymentController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  RxBool isLoading = false.obs;

  /// All transactions from API (raw data)
  RxList<dynamic> allPayments = <dynamic>[].obs;

  /// Payments filtered by date range (shown in UI)
  RxList<dynamic> payments = <dynamic>[].obs;

  /// Selected date for filtering
  Rx<DateTime> selectedDate = DateTime.now().obs;

  /// Selected range type: day, week, month, year
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

      // Save all payments
      allPayments.assignAll(response.data["payments"] ?? []);

      // Apply default filter (today)
      applyFilter();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load payments",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Change selected date from calendar
  void changeSelectedDate(DateTime date) {
    selectedDate.value = date;
    applyFilter();
  }

  /// Change between day/week/month/year
  void changeRangeType(String type) {
    selectedRangeType.value = type;
    applyFilter();
  }

  /// Apply date + range filter
  void applyFilter() {
    if (allPayments.isEmpty) {
      payments.clear();
      return;
    }

    final DateTime base = selectedDate.value;

    late DateTime start;
    late DateTime end;

    switch (selectedRangeType.value) {
      case 'day':
        start = DateTime(base.year, base.month, base.day);
        end = start.add(const Duration(days: 1));
        break;

      case 'week':
        final int diff = base.weekday - DateTime.monday;
        start = DateTime(
          base.year,
          base.month,
          base.day,
        ).subtract(Duration(days: diff));
        end = start.add(const Duration(days: 7));
        break;

      case 'month':
        start = DateTime(base.year, base.month, 1);
        end = (base.month == 12)
            ? DateTime(base.year + 1, 1, 1)
            : DateTime(base.year, base.month + 1, 1);
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
      try {
        if (p["transacted_at"] == null) return false;

        final dt = DateTime.parse(p["transacted_at"].toString());
        return dt.isAfter(start) && dt.isBefore(end);
      } catch (_) {
        return false;
      }
    }).toList();

    payments.assignAll(filtered);
  }
}
