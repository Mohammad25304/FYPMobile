import 'package:cashpilot/Core/Network/PaaymentApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'WalletController.dart';
import 'HomeController.dart';

class PayEducationController extends GetxController {
  final PaymentApi _api = PaymentApi();
  final Dio _dio = DioClient().getInstance();

  final WalletController walletController = Get.put(WalletController());
  final HomeController homeController = Get.find();

  late Map<String, dynamic> provider;

  // Form Controllers
  final studentIdController = TextEditingController();
  final studentNameController = TextEditingController();
  final semesterController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  // Observable State
  final selectedCurrency = 'USD'.obs;
  final selectedPaymentType = 'Tuition Fee'.obs;
  final amount = 0.0.obs;

  // Fee State
  final fee = 0.0.obs;
  final total = 0.0.obs;
  final isFetchingFee = false.obs;

  // Loading State
  final isLoading = false.obs;

  // Payment Type Options
  final List<String> paymentTypes = [
    'Tuition Fee',
    'Registration Fee',
    'Exam Fee',
    'Library Fee',
    'Lab Fee',
    'Sports Fee',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();

    // Safely get provider data
    try {
      provider = Get.arguments ?? {};
      if (provider.isEmpty) {
        Get.back();
        Get.snackbar(
          'Error',
          'Invalid provider data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to load provider information',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Listen to amount changes for fee calculation
    amountController.addListener(() {
      final newAmount = double.tryParse(amountController.text) ?? 0;
      if (newAmount != amount.value) {
        amount.value = newAmount;
        fetchFeePreview();
      }
    });
  }

  // Update fees when currency changes
  void onCurrencyChanged(String currency) {
    selectedCurrency.value = currency;
    fetchFeePreview();
  }

  // Update payment type
  void onPaymentTypeChanged(String type) {
    selectedPaymentType.value = type;
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
          "context": "education_payment",
          "service_id": provider['id'],
          "currency": selectedCurrency.value,
          "amount": amount.value,
        },
      );

      fee.value = (response.data['fee'] ?? 0).toDouble();
      total.value = (response.data['total'] ?? amount.value).toDouble();
    } catch (e) {
      // Fallback to zero fee if preview fails
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
    // Student ID validation
    if (studentIdController.text.trim().isEmpty) {
      return 'Please enter student ID';
    }

    if (studentIdController.text.trim().length < 3) {
      return 'Student ID is too short';
    }

    // Student Name validation
    if (studentNameController.text.trim().isEmpty) {
      return 'Please enter student name';
    }

    if (studentNameController.text.trim().length < 3) {
      return 'Student name is too short';
    }

    // Semester/Year validation
    if (semesterController.text.trim().isEmpty) {
      return 'Please enter semester/year';
    }

    // Amount validation
    if (amount.value <= 0) {
      return 'Please enter a valid amount';
    }

    if (amount.value < 1) {
      return 'Minimum payment amount is 1 ${selectedCurrency.value}';
    }

    return null;
  }

  // =============================
  // PAY EDUCATION
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

      await _api.payEducation(
        provider: provider['name'],
        serviceId: provider['id'],
        studentId: studentIdController.text.trim(),
        studentName: studentNameController.text.trim(),
        semester: semesterController.text.trim(),
        paymentType: selectedPaymentType.value,
        amount: amount.value,
        currency: selectedCurrency.value,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      // Clear fields after success
      studentIdController.clear();
      studentNameController.clear();
      semesterController.clear();
      amountController.clear();
      notesController.clear();

      // Refresh wallet and dashboard
      try {
        await Future.wait([
          walletController.refreshAll(),
          homeController.fetchDashboardData(),
        ]);
      } catch (e) {
        // Log but don't fail the payment if refresh fails
        debugPrint('Failed to refresh data: $e');
      }

      // Success message
      Get.snackbar(
        'Payment Successful ✅',
        'Your education payment was completed successfully.',
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

      // Safely navigate back
      if (Get.isRegistered<PayEducationController>()) {
        Get.back();
      }
    } on DioException catch (e) {
      String errorMessage = 'Unable to complete payment. Please try again.';

      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            errorMessage =
                e.response!.data['message'] ?? 'Invalid payment data';
            break;
          case 402:
            errorMessage = 'Insufficient balance in your wallet';
            break;
          case 404:
            errorMessage = 'Institution or student not found';
            break;
          case 422:
            errorMessage = 'Invalid student ID or payment details';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later';
            break;
          default:
            errorMessage = 'Payment failed. Please contact support';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server timeout. Please try again';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Network error. Please check your connection';
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
    } catch (e) {
      Get.snackbar(
        'Payment Failed ❌',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );

      debugPrint('Payment error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    studentIdController.dispose();
    studentNameController.dispose();
    semesterController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
