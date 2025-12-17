import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Controllers/HomeController.dart';

class CashPickupController extends GetxController {
  // Text controllers
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();
  final receiverEmailController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  // State
  final selectedCurrency = 'USD'.obs;
  final amount = 0.0.obs;
  final isSending = false.obs;

  // Dependencies
  final WalletController walletController = Get.find<WalletController>();
  final HomeController homeController = Get.find<HomeController>();
  final Dio _dio = DioClient().getInstance();

  // =============================
  // COMPUTED
  // =============================
  double get availableBalance {
    switch (selectedCurrency.value) {
      case 'USD':
        return walletController.usdBalance.value;
      case 'EUR':
        return walletController.eurBalance.value;
      case 'LBP':
        return walletController.lbpBalance.value;
      default:
        return 0;
    }
  }

  String get currencySymbol {
    switch (selectedCurrency.value) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'LBP':
        return 'LL';
      default:
        return '\$';
    }
  }

  double calculateFee() => amount.value * 0.01;

  bool get canSend {
    final total = amount.value + calculateFee();
    return receiverNameController.text.trim().isNotEmpty &&
        receiverPhoneController.text.trim().isNotEmpty &&
        amount.value > 0 &&
        total <= availableBalance &&
        !isSending.value;
  }

  // =============================
  // ACTIONS
  // =============================
  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
    // optional: reset amount when currency changes
    // amountController.clear();
    // amount.value = 0;
  }

  void updateAmount(String value) {
    final parsed = double.tryParse(value);
    amount.value = parsed ?? 0.0;
  }

  // =============================
  // API CALL
  // =============================
  Future<void> sendCashPickup() async {
    if (!canSend) return;

    isSending.value = true;

    try {
      final response = await _dio.post(
        "cash-pickup/send",
        data: {
          "receiver_full_name": receiverNameController.text.trim(),
          "receiver_phone": receiverPhoneController.text.trim(),
          "receiver_email": receiverEmailController.text.trim().isEmpty
              ? null
              : receiverEmailController.text.trim(),
          "amount": amount.value,
          "currency": selectedCurrency.value,
          "note": noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        },
      );

      final data = response.data ?? {};
      final code = (data["pickup_code"] ?? "").toString();

      // ✅ Immediate UI update (Recent Transactions + Expenses)
      // This is safe because backend already succeeded, and then we sync again below.
      final fee = calculateFee();
      final total = amount.value + fee;

      // walletController.addTransaction({
      //   'title': 'Cash Pickup',
      //   'amount': total,
      //   'type': 'debit',
      //   'currency': selectedCurrency.value,
      //   'category': 'send', // or 'cash_pickup' if you want
      //   'date': DateTime.now().toIso8601String(),
      // });

      // Refresh wallet & dashboard from backend (source of truth)
      await walletController.refreshAll();
      await homeController.fetchDashboardData();

      _showSuccessDialog(code);
    } catch (e) {
      debugPrint("❌ Cash Pickup Error: $e");

      Get.snackbar(
        "Error",
        e is DioException
            ? (e.response?.data["message"]?.toString() ?? "Failed to send cash")
            : "Failed to send cash",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> cancelCashPickup(int transactionId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _dio.post("cash-pickup/$transactionId/cancel");
      final msg = (response.data?["message"] ?? "Cash pickup cancelled")
          .toString();

      Get.back(); // close loading

      // Optional immediate UI update:
      // You *can* also add a "refund" credit transaction locally.
      // Backend will return it on next fetchWalletData anyway.
      // walletController.addTransaction({
      //   'title': 'Cash Pickup Refund',
      //   'amount': 0.0, // unknown here unless you pass it, so we rely on fetch
      //   'type': 'credit',
      //   'date': DateTime.now().toIso8601String(),
      //   'currency': selectedCurrency.value,
      // });

      await walletController.fetchWalletData();
      await homeController.fetchDashboardData();

      Get.snackbar(
        "Cancelled",
        msg,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();

      Get.snackbar(
        "Error",
        "Failed to cancel cash pickup",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // =============================
  // SUCCESS UI
  // =============================
  void _showSuccessDialog(String pickupCode) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Cash Ready for Pickup",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text("Pickup Code", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 6),
              Text(
                pickupCode,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _clear();
                  Get.back(); // close dialog
                  Get.back(); // back to wallet
                },
                child: const Text("Back to Wallet"),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _clear() {
    receiverNameController.clear();
    receiverPhoneController.clear();
    receiverEmailController.clear();
    amountController.clear();
    noteController.clear();
    amount.value = 0.0;
  }

  @override
  void onClose() {
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    receiverEmailController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
