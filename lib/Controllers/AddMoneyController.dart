import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Controllers/HomeController.dart';

class ReceiveCashPickupController extends GetxController {
  final pickupCodeController = TextEditingController();
  final receiverPhoneController = TextEditingController();

  final isLoading = false.obs;

  final Dio _dio = DioClient().getInstance();
  final WalletController walletController = Get.find();
  final HomeController homeController = Get.find();

  bool get canReceive =>
      pickupCodeController.text.trim().isNotEmpty &&
      receiverPhoneController.text.trim().isNotEmpty &&
      !isLoading.value;

  Future<void> receiveCashPickup() async {
    if (!canReceive) return;

    isLoading.value = true;

    try {
      final response = await _dio.post(
        "cash-pickup/receive",
        data: {
          "pickup_code": pickupCodeController.text.trim(),
          "receiver_phone": receiverPhoneController.text.trim(),
        },
      );

      final msg = response.data["message"] ?? "Cash received successfully";

      await walletController.refreshAll();
      await homeController.fetchDashboardData();

      Get.snackbar(
        "Success",
        msg,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        "Error",
        e is DioException
            ? e.response?.data["message"] ?? "Failed to receive cash"
            : "Failed to receive cash",
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
