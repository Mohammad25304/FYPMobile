import 'package:cashpilot/Core/Network/PaaymentApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'WalletController.dart';
import 'HomeController.dart';

class PayStreamingController extends GetxController {
  final PaymentApi _api = PaymentApi();
  final Dio _dio = DioClient().getInstance();

  final WalletController walletController = Get.put(WalletController());
  final HomeController homeController = Get.find();

  late Map<String, dynamic> provider;

  final emailController = TextEditingController();
  final notesController = TextEditingController();

  final selectedCurrency = 'USD'.obs;
  final selectedPlan = 'basic'.obs;
  final selectedDuration = 1.obs;

  // Plan prices (base monthly prices in USD)
  final basicPrice = 8.99.obs;
  final standardPrice = 13.99.obs;
  final premiumPrice = 17.99.obs;

  final amount = 0.0.obs;
  final discount = 0.0.obs;

  // 🔐 FEES (backend-driven)
  final fee = 0.0.obs;
  final total = 0.0.obs;
  final isFetchingFee = false.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    provider = Get.arguments;

    // Initialize with basic plan
    calculateAmount();
  }

  // =============================
  // PLAN SELECTION
  // =============================
  void onPlanChanged(String plan) {
    selectedPlan.value = plan;
    calculateAmount();
  }

  // =============================
  // CURRENCY CHANGE
  // =============================
  void onCurrencyChanged(String currency) {
    selectedCurrency.value = currency;
    convertPrices(currency);
    calculateAmount();
  }

  // =============================
  // DURATION CHANGE
  // =============================
  void onDurationChanged(int duration) {
    selectedDuration.value = duration;
    calculateAmount();
  }

  // =============================
  // CONVERT PRICES BASED ON CURRENCY
  // =============================
  void convertPrices(String currency) {
    // Base prices in USD
    const baseBasic = 8.99;
    const baseStandard = 13.99;
    const basePremium = 17.99;

    // Conversion rates (you can make these dynamic via API)
    double rate = 1.0;
    if (currency == 'EUR') {
      rate = 0.92;
    } else if (currency == 'LBP') {
      rate = 89500.0;
    }

    basicPrice.value = baseBasic * rate;
    standardPrice.value = baseStandard * rate;
    premiumPrice.value = basePremium * rate;
  }

  // =============================
  // CALCULATE AMOUNT & DISCOUNT
  // =============================
  void calculateAmount() {
    double basePrice = 0;

    // Get base price based on selected plan
    switch (selectedPlan.value) {
      case 'basic':
        basePrice = basicPrice.value;
        break;
      case 'standard':
        basePrice = standardPrice.value;
        break;
      case 'premium':
        basePrice = premiumPrice.value;
        break;
    }

    // Calculate total for duration
    double subtotal = basePrice * selectedDuration.value;

    // Apply discounts for longer durations
    double discountPercent = 0;
    if (selectedDuration.value == 3) {
      discountPercent = 0.05; // 5% off
    } else if (selectedDuration.value == 6) {
      discountPercent = 0.10; // 10% off
    } else if (selectedDuration.value == 12) {
      discountPercent = 0.15; // 15% off
    }

    discount.value = subtotal * discountPercent;
    amount.value = subtotal - discount.value;

    // Fetch fees after amount is calculated
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
          "context": "streaming_payment",
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
    if (emailController.text.trim().isEmpty) {
      return 'Please enter your email address';
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      return 'Please enter a valid email address';
    }

    if (amount.value <= 0) {
      return 'Please select a subscription plan';
    }

    return null;
  }

  // =============================
  // PAY STREAMING
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

      await _api.payStreaming(
        provider: provider['name'],
        serviceId: provider['id'],
        email: emailController.text.trim(),
        plan: selectedPlan.value,
        duration: selectedDuration.value,
        amount: amount.value,
        currency: selectedCurrency.value,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      // Clear fields after success
      emailController.clear();
      notesController.clear();
      selectedPlan.value = 'basic';
      selectedDuration.value = 1;

      // Refresh data
      await walletController.refreshAll();
      await homeController.fetchDashboardData();

      // Success message
      Get.snackbar(
        'Subscription Successful ✅',
        'Your streaming subscription has been activated.',
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
      String errorMessage =
          'Unable to complete subscription. Please try again.';

      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.statusCode == 402) {
          errorMessage = 'Insufficient balance in your wallet';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Streaming service not found';
        } else if (e.response?.statusCode == 409) {
          errorMessage = 'Account already has an active subscription';
        } else if (e.response?.statusCode == 422) {
          errorMessage = 'Invalid email or subscription details';
        }
      }

      Get.snackbar(
        'Subscription Failed ❌',
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
    emailController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
