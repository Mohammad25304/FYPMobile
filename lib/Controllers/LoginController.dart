import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:cashpilot/Core/Network/auth_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  final AuthService _authService = AuthService();

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
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
    password.dispose();
    super.onClose();
  }
}
