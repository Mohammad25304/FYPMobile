import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerificationController extends GetxController {
  final otp = TextEditingController();

  void verifyOtp() {
    // TODO: Add API call to verify OTP from backend
    if (otp.text.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP');
    } else {
      Get.snackbar('Success', 'Account verified successfully!');
      Get.offAllNamed('/login');
    }
  }
}
