import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Views/ForgetPasswordOtp.dart';
import 'package:cashpilot/Views/ResetPassword.dart';
import 'package:cashpilot/Bindings/ForgetPasswordOTPBinding.dart';
import 'package:cashpilot/Bindings/ResetPasswordBinding.dart';

class ForgetPasswordController extends GetxController {
  final Dio dio = Dio();

  // ✅ Update this to your actual backend IP
  final String baseUrl = 'http://192.168.1.65:8000/api';

  // Text Controllers
  late TextEditingController emailController;
  late TextEditingController otpController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // Observables
  RxBool isLoading = false.obs;
  RxBool obscurePassword = true.obs;
  RxString resetToken = ''.obs;
  RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    otpController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Configure Dio
    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // =====================================================
  // STEP 1: SEND OTP TO EMAIL
  // =====================================================
  Future<void> sendOtp() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      debugPrint('🔄 Sending OTP to: ${emailController.text}');
      debugPrint('📡 API URL: $baseUrl/forgot-password');

      final response = await dio.post(
        '$baseUrl/forgot-password',
        data: {'email': emailController.text.trim()},
      );

      debugPrint('✅ Response: ${response.statusCode} - ${response.data}');

      userEmail.value = emailController.text.trim();

      Get.snackbar(
        'Success',
        response.data['message'] ?? 'OTP sent to your email',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to OTP screen after a short delay
      await Future.delayed(const Duration(milliseconds: 800));
      debugPrint('🚀 Attempting navigation to OTP screen');
      // Use Get.to() instead of Get.toNamed() for safer navigation
      Get.to(
        () => const ForgetPasswordOTP(),
        binding: ForgetPasswordOTPBinding(),
        transition: Transition.fadeIn,
      );
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.type}');
      debugPrint('📋 Status Code: ${e.response?.statusCode}');
      debugPrint('📝 Response: ${e.response?.data}');
      debugPrint('💬 Message: ${e.message}');

      String errorMsg = 'Failed to send OTP';

      if (e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      } else if (e.message != null) {
        errorMsg = e.message ?? errorMsg;
      }

      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // STEP 2: VERIFY OTP
  // =====================================================
  Future<void> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the OTP',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      debugPrint('🔄 Verifying OTP for: ${userEmail.value}');
      debugPrint('📡 OTP Code: ${otpController.text}');

      final response = await dio.post(
        '$baseUrl/verify-password-reset-otp',
        data: {'email': userEmail.value, 'otp_code': otpController.text.trim()},
      );

      debugPrint('✅ Response: ${response.statusCode} - ${response.data}');

      resetToken.value = response.data['reset_token'] ?? '';

      Get.snackbar(
        'Success',
        response.data['message'] ?? 'OTP verified successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to reset password screen after a short delay
      await Future.delayed(const Duration(milliseconds: 800));
      Get.to(
        () => const ResetPassword(),
        binding: ResetPasswordBinding(),
        transition: Transition.fadeIn,
      );
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.type}');
      debugPrint('📋 Status Code: ${e.response?.statusCode}');
      debugPrint('📝 Response: ${e.response?.data}');

      String errorMsg = 'Failed to verify OTP';

      if (e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }

      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // STEP 3: RESET PASSWORD
  // =====================================================
  Future<void> resetPassword() async {
    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter new password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordController.text.length < 4) {
      Get.snackbar(
        'Error',
        'Password must be at least 4 digits',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      debugPrint('🔄 Resetting password for: ${userEmail.value}');

      final response = await dio.post(
        '$baseUrl/reset-password',
        data: {
          'email': userEmail.value,
          'reset_token': resetToken.value,
          'new_password': passwordController.text,
          'new_password_confirmation': confirmPasswordController.text,
        },
      );

      debugPrint('✅ Response: ${response.statusCode} - ${response.data}');

      Get.snackbar(
        'Success',
        response.data['message'] ?? 'Password reset successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Clean up
      cleanupAfterReset();

      // Navigate back to login after a short delay
      await Future.delayed(const Duration(milliseconds: 800));
      Get.offAllNamed('/login');
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.type}');
      debugPrint('📋 Status Code: ${e.response?.statusCode}');
      debugPrint('📝 Response: ${e.response?.data}');

      String errorMsg = 'Failed to reset password';

      if (e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }

      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // RESEND OTP
  // =====================================================
  Future<void> resendOtp() async {
    isLoading.value = true;
    try {
      debugPrint('🔄 Resending OTP to: ${userEmail.value}');

      final response = await dio.post(
        '$baseUrl/forgot-password',
        data: {'email': userEmail.value},
      );

      debugPrint('✅ Response: ${response.statusCode}');

      Get.snackbar(
        'Success',
        'New OTP sent to your email',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.type}');

      String errorMsg = 'Failed to resend OTP';

      if (e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }

      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void cleanupAfterReset() {
    // Only clear the values, don't dispose
    emailController.clear();
    otpController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    resetToken.value = '';
    userEmail.value = '';
    // Do NOT dispose here - they're still needed for the next forgot password flow
  }
}
