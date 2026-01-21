import 'package:cashpilot/Controllers/NotificationController.dart';
import 'package:cashpilot/Core/Network/PaaymentApi.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'WalletController.dart';
import 'HomeController.dart';

class PayTelecomController extends GetxController {
  final PaymentApi _api = PaymentApi();
  final Dio _dio = DioClient().getInstance();

  final selectedCurrency = 'USD'.obs;
  final selectedCountryCode = '+961'.obs;
  final selectedCountry = 'Lebanon'.obs;

  final WalletController walletController = Get.find<WalletController>();
  final HomeController homeController = Get.find<HomeController>();

  late Map<String, dynamic> provider;

  final phoneController = TextEditingController();
  final amountController = TextEditingController();

  // 🔐 FEES (backend-driven)
  final amount = 0.0.obs;
  final fee = 0.0.obs;
  final total = 0.0.obs;
  final isFetchingFee = false.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    provider = Get.arguments;

    print('🔍 FULL PROVIDER DATA RECEIVED:');
    print('   Keys: ${provider.keys}');
    print('   Values: ${provider.values}');
    print('   ID: ${provider['id']}');
    print('   Code: ${provider['code']}');
    print('   Name: ${provider['name']}');

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

  Future<void> pay() async {
    print('🔥 PAY BUTTON CLICKED');

    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    // ✅ CHECK IF CODE EXISTS
    if (provider['code'] == null || provider['code'].toString().isEmpty) {
      Get.snackbar(
        'Provider Error',
        'Invalid provider data. Please select provider again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid number for the amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final fullPhone = '${selectedCountryCode.value}${phoneController.text}';
    print('📤 Sending telecom payment request');
    print('🏢 Provider: ${provider['name']}');
    print('🔑 Provider Code: ${provider['code']}');
    print('📱 Phone: $fullPhone');
    print('💰 Amount: $amount');

    try {
      isLoading.value = true;

      await _api.payTelecom(
        provider: provider['name'],
        providerCode: provider['code'],
        phone: fullPhone,
        amount: amount,
        currency: selectedCurrency.value,
      );

      phoneController.clear();
      amountController.clear();

      await walletController.fetchWalletData();
      await homeController.fetchDashboardData();

      final notificationController = Get.find<NotificationController>();
      await notificationController.fetchNotifications();

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
      print('❌ Payment error: $e');
      Get.snackbar(
        'Payment Failed ❌',
        e.toString().replaceAll('Exception: ', ''),
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
    phoneController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
