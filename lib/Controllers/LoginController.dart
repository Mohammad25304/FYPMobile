import 'package:cashpilot/Controllers/HomeController.dart';
import 'package:cashpilot/Controllers/SendMoneyController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:cashpilot/Core/Network/auth_service.dart';
import 'package:cashpilot/Core/Services/FcmService.dart';
import 'package:cashpilot/Core/Storage/SessionManager.dart'; // Add this import
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  late TextEditingController email;
  late TextEditingController password;
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    email = TextEditingController();
    password = TextEditingController();
    debugPrint('✅ LoginController initialized');

    // Clear fields when arriving at login screen
    clearFields();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // ✅ NEW METHOD: Clear all fields
  void clearFields() {
    email.clear();
    password.clear();
    obscurePassword.value = true;
    debugPrint('✅ Login fields cleared');
  }

  Future<void> login() async {
    if (email.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (password.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your password",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Create form data
      final formData = dio.FormData.fromMap({
        "email": email.text,
        "password": password.text,
      });

      // 🔥 REAL API CALL
      final response = await _authService.login(formData);

      isLoading.value = false;
      await FcmService.sendTokenToBackend();

      // SUCCESS
      Get.snackbar(
        "Success",
        response.data["message"],
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // ✅ SAVE TOKEN AND EMAIL TO STORAGE
      final token = response.data["token"] ?? response.data["access_token"];
      final userEmail = email.text;

      if (token != null) {
        await SessionManager.saveSession(token: token, email: userEmail);
        debugPrint('✅ Token saved: $token');
      } else {
        debugPrint('❌ No token found in response');
        Get.snackbar(
          "Error",
          "Token not received from server",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      // Fetch home dashboard data after successful login
      final homeController = Get.put(HomeController());
      await homeController.fetchDashboardData();
      // Fetch wallet data after successful login
      final walletController = Get.put(WalletController());
      await walletController.fetchWalletData();

      Get.offAllNamed('/home');
    } on DioException catch (e) {
      isLoading.value = false;

      // Extract backend error message
      String message = e.response?.data["message"] ?? "Login failed";

      Get.snackbar(
        "Error",
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    debugPrint('🧹 LoginController closed');
    email.dispose();
    password.dispose();
    obscurePassword.value = true;
    super.onClose();
  }
}
