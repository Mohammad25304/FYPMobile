import 'package:cashpilot/Core/Network/PaaymentApi.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'WalletController.dart';
import 'HomeController.dart';

class PayTelecomController extends GetxController {
  final PaymentApi _api = PaymentApi();
  final selectedCurrency = 'USD'.obs;
  final WalletController walletController = Get.put<WalletController>(
    WalletController(),
  );
  final HomeController homeController = Get.put<HomeController>(
    HomeController(),
  );

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
        phone: phoneController.text,
        amount: double.parse(amountController.text),
        currency: selectedCurrency.value,
      );

      // ✅ REFRESH DATA
      await walletController.fetchWalletData();
      await homeController.fetchDashboardData();
      // await transactionsController.fetchTransactions(); // if exists

      Get.snackbar(
        'Success',
        'Telecom payment completed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Payment Failed',
        'Unable to complete payment',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
