import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Controllers/HomeController.dart';

class AddMoneyController extends GetxController {
  // Text controllers
  final pickupCodeController = TextEditingController();
  final receiverPhoneController = TextEditingController();

  // Reactive values (IMPORTANT)
  final pickupCode = ''.obs;
  final receiverPhone = ''.obs;

  final isLoading = false.obs;

  final Dio _dio = DioClient().getInstance();
  final WalletController walletController = Get.find();
  final HomeController homeController = Get.find();

  // =============================
  // LIFECYCLE
  // =============================
  @override
  void onInit() {
    pickupCodeController.addListener(() {
      pickupCode.value = pickupCodeController.text.trim();
    });

    receiverPhoneController.addListener(() {
      receiverPhone.value = receiverPhoneController.text.trim();
    });

    super.onInit();
  }

  // =============================
  // COMPUTED
  // =============================
  bool get canReceive =>
      pickupCode.value.isNotEmpty &&
      receiverPhone.value.isNotEmpty &&
      !isLoading.value;

  // =============================
  // API CALL
  // =============================
  Future<void> receiveCashPickup() async {
    if (!canReceive) return;

    isLoading.value = true;

    try {
      final response = await _dio.post(
        "cash-pickup/receive",
        data: {
          "pickup_code": pickupCode.value,
          "receiver_phone": receiverPhone.value,
        },
      );

      await walletController.refreshAll();
      await homeController.fetchDashboardData();

      Get.snackbar(
        "Money Received 🎉",
        "The amount has been added to your wallet and recorded in your history.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        Get.back();
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        e is DioException
            ? e.response?.data["message"] ?? "Failed to receive cash"
            : "Failed to receive cash",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    pickupCodeController.dispose();
    receiverPhoneController.dispose();
    super.onClose();
  }
}
