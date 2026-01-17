import 'package:cashpilot/Core/Network/PaaymentApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'WalletController.dart';
import 'HomeController.dart';

class PayInternetController extends GetxController {
  final PaymentApi _api = PaymentApi();
  final Dio _dio = DioClient().getInstance();

  final WalletController walletController = Get.isRegistered<WalletController>()
      ? Get.find<WalletController>()
      : Get.put(WalletController());
  final HomeController homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  late Map<String, dynamic> provider;

  final accountController = TextEditingController();
  final amountController = TextEditingController();

  final selectedCurrency = 'USD'.obs;
  final amount = 0.0.obs;

  // 🔐 FEES (backend-driven)
  final fee = 0.0.obs;
  final total = 0.0.obs;
  final isFetchingFee = false.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    provider = Get.arguments;

    // Listen to amount changes
    amountController.addListener(() {
      amount.value = double.tryParse(amountController.text) ?? 0;
      fetchFeePreview();
    });
  }

  // Update fees when currency changes
  void onCurrencyChanged(String currency) {
    selectedCurrency.value = currency;
    fetchFeePreview();
  }

  // =============================
  // 🔐 FEE PREVIEW
  // =============================
  Future<void> fetchFeePreview() async {
    if (amount.value <= 0) {
      fee.value = 0;
      total.value = 0;
      return;
    }

    try {
      isFetchingFee.value = true;

      final response = await _dio.post(
        "fees/preview",
        data: {
          "context": "bill_payment",
          "service_id": provider['id'],
          "currency": selectedCurrency.value,
          "amount": amount.value,
        },
      );

      fee.value = (response.data['fee'] ?? 0).toDouble();
      total.value = (response.data['total'] ?? amount.value).toDouble();
    } catch (e) {
      fee.value = 0;
      total.value = amount.value;
    } finally {
      isFetchingFee.value = false;
    }
  }

  // =============================
  // VALIDATION
  // =============================
  String? validateInputs() {
    if (accountController.text.trim().isEmpty) {
      return 'Please enter your account number';
    }

    if (accountController.text.trim().length < 4) {
      return 'Account number is too short';
    }

    if (amount.value <= 0) {
      return 'Please enter a valid amount';
    }

    if (amount.value < 1) {
      return 'Minimum amount is 1 ${selectedCurrency.value}';
    }

    return null;
  }

  // =============================
  // PAY INTERNET
  // =============================
  Future<void> pay() async {
    // Validate inputs
    final error = validateInputs();
    if (error != null) {
      Get.snackbar(
        'Validation Error',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isLoading.value = true;

      await _api.payInternet(
        provider: provider['name'],
        accountNumber: accountController.text.trim(),
        amount: amount.value,
        currency: selectedCurrency.value,
      );

      // Clear fields after success
      accountController.clear();
      amountController.clear();

      // Refresh data
      await walletController.refreshAll();
      await homeController.fetchDashboardData();

      // Success message
      Get.snackbar(
        'Payment Successful ✅',
        'Your internet bill payment was completed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );

      // Delay navigation to show success message
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
    } catch (e) {
      String errorMessage = 'Unable to complete payment. Please try again.';

      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.statusCode == 402) {
          errorMessage = 'Insufficient balance in your wallet';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Service provider not found';
        }
      }

      Get.snackbar(
        'Payment Failed ❌',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    accountController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
