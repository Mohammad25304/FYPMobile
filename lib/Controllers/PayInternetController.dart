import 'package:cashpilot/Core/Network/PaaymentApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'WalletController.dart';
import 'HomeController.dart';

class PayInternetController extends GetxController {
  final PaymentApi _api = PaymentApi();

  final WalletController walletController = Get.put(WalletController());
  final HomeController homeController = Get.put(HomeController());

  late Map<String, dynamic> provider;

  final accountController = TextEditingController();
  final amountController = TextEditingController();

  final selectedCurrency = 'USD'.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    provider = Get.arguments;
  }

  Future<void> pay() async {
    try {
      isLoading.value = true;

      await _api.payInternet(
        provider: provider['name'],
        accountNumber: accountController.text,
        amount: double.parse(amountController.text),
        currency: selectedCurrency.value,
      );

      await walletController.refreshAll();
      await homeController.fetchDashboardData();

      Get.snackbar(
        'Success',
        'Internet payment completed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Payment failed');
    } finally {
      isLoading.value = false;
    }
  }
}
