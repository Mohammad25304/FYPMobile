import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:cashpilot/Core/Network/auth_service.dart';
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

      // SUCCESS
      Get.snackbar(
        "Success",
        response.data["message"],
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Save token to storage later if needed
      // final token = response.data["token"];

      Get.toNamed('/home');
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
    email.clear();
    password.clear();
    obscurePassword.value = true;
    // Don't dispose - just clear the values
    super.onClose();
  }
}
