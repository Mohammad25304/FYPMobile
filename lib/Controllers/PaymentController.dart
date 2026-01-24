import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class PaymentController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  RxBool isLoading = false.obs;

  RxList<Map<String, dynamic>> allPayments = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> payments = <Map<String, dynamic>>[].obs;

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
      final List list = response.data["payments"] ?? [];

      // 🔍 DEBUG
      print("========== DEBUG: PAYMENTS FROM API ==========");
      for (var p in list) {
        print("Title: ${p['title']}");
        print("  Type: ${p['type']}");
        print("  Amount: ${p['amount']}");
        print("  Category: ${p['category']}");
        print("---");
      }
      print("==============================================");

      allPayments.assignAll(
        list.map<Map<String, dynamic>>((p) {
          // ✅ CRITICAL: Keep the type from backend, don't override it
          final type = p['type'] ?? 'debit';
          final amount = double.tryParse('${p['amount']}') ?? 0.0;

          return {
            'id': p['id'],
            'title': p['title'] ?? 'Transaction',
            'amount': amount,
            'currency': p['currency'] ?? 'USD',
            'type': type, // ✅ DON'T change this based on category
            'category': p['category'] ?? 'transfer',
            'date': p['transacted_at']?.toString().substring(0, 10) ?? '',
            'transacted_at': p['transacted_at'],
          };
        }).toList(),
      );

      applyFilter();
    } catch (e) {
      print("❌ ERROR: $e");
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
      final raw = p['transacted_at'];
      if (raw == null) return true;

      try {
        final dt = DateTime.parse(raw.toString());
        return !dt.isBefore(start) && dt.isBefore(end);
      } catch (_) {
        return true;
      }
    }).toList();

    print("✅ FILTERED PAYMENTS: ${filtered.length}");
    for (var p in filtered) {
      print("  - ${p['title']}: type=${p['type']}, amount=${p['amount']}");
    }

    payments.assignAll(filtered);
  }
}
