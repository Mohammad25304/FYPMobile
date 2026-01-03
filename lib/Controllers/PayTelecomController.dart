import 'package:cashpilot/Core/Network/PaaymentApi.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'WalletController.dart';
import 'HomeController.dart';

class PayTelecomController extends GetxController {
  final PaymentApi _api = PaymentApi();
  final selectedCurrency = 'USD'.obs;

  final WalletController walletController = Get.put(WalletController());
  final HomeController homeController = Get.put(HomeController());

  late Map<String, dynamic> provider;

  final phoneController = TextEditingController();
  final amountController = TextEditingController();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    provider = Get.arguments;
  }

  Future<void> pay() async {
    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;

      await _api.payTelecom(
        provider: provider['name'],
        provider_id: provider['id'],
        phone: phoneController.text,
        amount: double.parse(amountController.text),
        currency: selectedCurrency.value,
      );

      // 🔥 CLEAR FIELDS AFTER SUCCESS
      phoneController.clear();
      amountController.clear();

      await walletController.fetchWalletData();
      await homeController.fetchDashboardData();

      // ✅ SUCCESS SNACKBAR
      Get.snackbar(
        'Payment Successful ✅',
        'Your telecom recharge was completed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Payment Failed ❌',
        'Unable to complete payment',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
