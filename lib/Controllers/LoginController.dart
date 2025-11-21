import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController password = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (password.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;

    // TODO: Add your login API call here
    // Example:
    // try {
    //   final response = await http.post(
    //     Uri.parse('YOUR_API_URL/login'),
    //     body: {'password': password.text},
    //   );
    //   // Handle response
    // } catch (e) {
    //   // Handle error
    // }

    await Future.delayed(const Duration(seconds: 2)); // Simulated delay

    isLoading.value = false;

    // Navigate to home or show success
    Get.snackbar(
      'Success',
      'Login successful!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );

    Get.toNamed('/home');
  }

  @override
  void onClose() {
    password.dispose();
    super.onClose();
  }
}
