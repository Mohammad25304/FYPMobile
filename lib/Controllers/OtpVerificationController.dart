import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerificationController extends GetxController {
  final otpControllers = List.generate(6, (_) => TextEditingController());
  var remainingSeconds = 60.obs;
  var canResend = false.obs;

  late String email;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments["email"];
    startTimer();
  }

  // TIMER LOGIC
  void startTimer() async {
    canResend.value = false;
    remainingSeconds.value = 60;

    for (int i = 60; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      remainingSeconds.value--;

      if (remainingSeconds.value == 0) {
        canResend.value = true;
      }
    }
  }

  // 🔥 VERIFY OTP
  Future<void> verifyOtp() async {
    final otp = otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      Get.snackbar("Error", "Enter the full 6-digit OTP");
      return;
    }

    try {
      // Loading Dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final dio = Dio(BaseOptions(baseUrl: "http://192.168.98.86:8000/api/"));

      final response = await dio.post(
        "verify-otp",
        data: {"email": email, "otp_code": otp},
      );

      Get.back(); // Close loader

      // SUCCESS MESSAGE
      Get.snackbar(
        "Verified 🎉",
        "Your account has been successfully verified!",
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to login page
      Get.offAllNamed("/login");
    } catch (e) {
      Get.back(); // Close loader
      if (e is DioException) {
        Get.snackbar(
          "Error",
          e.response?.data["message"] ?? "Invalid OTP. Try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // 🔄 RESEND OTP
  Future<void> resendOtp() async {
    if (!canResend.value) return;

    final dio = Dio(BaseOptions(baseUrl: "http://192.168.98.86:8000/api/"));

    try {
      final response = await dio.post("resend-otp", data: {"email": email});

      Get.snackbar(
        "OTP Sent",
        "A new OTP has been sent to your email.",
        backgroundColor: const Color(0xFF2196F3),
        colorText: Colors.white,
      );

      startTimer();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unable to resend OTP",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
