import 'package:get/get.dart';
import 'dart:convert';

class AddMoneyController extends GetxController {
  // Form fields
  var transactionId = ''.obs;
  var senderName = ''.obs;
  var userPhone = ''.obs;
  var amount = ''.obs;

  // For loader
  var isLoading = false.obs;

  // Handle QR result
  void handleQrScan(String qrData) {
    try {
      final data = jsonDecode(qrData);

      transactionId.value = data['transaction_id'] ?? '';
      senderName.value = data['sender_name'] ?? '';
      amount.value = data['amount'].toString();
    } catch (e) {
      Get.snackbar("Invalid QR", "QR format incorrect");
    }
  }

  // Submit request
  Future<void> submitAddMoney() async {
    if (transactionId.isEmpty || senderName.isEmpty || userPhone.isEmpty) {
      Get.snackbar("Missing info", "Please fill all fields");
      return;
    }

    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 2)); // Simulate API

    isLoading.value = false;

    Get.snackbar("Success", "Money added to your wallet");
    Get.back();
  }
}
