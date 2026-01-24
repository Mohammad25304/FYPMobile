import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:cashpilot/Core/Storage/SessionManager.dart';
import 'package:cashpilot/Controllers/LoginController.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  var isLoading = false.obs;
  var isSavingProfile = false.obs;
  var isChangingPassword = false.obs;
  var isDeleting = false.obs;
  var isDeletingAccount = false.obs;

  // User data
  var firstName = ''.obs;
  var lastName = ''.obs;
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var status = 'pending'.obs;
  var accountType = 'basic'.obs;
  var avatarUrl = ''.obs;

  // Documents
  var idFrontUrl = ''.obs;
  var idBackUrl = ''.obs;
  var selfieUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;

      final response = await _dio.get('profile');
      final data = response.data;

      firstName.value = data['first_name'] ?? '';
      lastName.value = data['last_name'] ?? '';
      name.value = '${firstName.value} ${lastName.value}'.trim();
      email.value = data['email'] ?? '';
      phone.value = data['phone']?.toString() ?? '';
      status.value = data['status'] ?? 'pending';
      accountType.value = data['account_type'] ?? 'basic';
      avatarUrl.value = data['avatar_url'] ?? '';

      final docs = data['documents'] ?? {};
      idFrontUrl.value = docs['id_front'] ?? '';
      idBackUrl.value = docs['id_back'] ?? '';
      selfieUrl.value = docs['selfie'] ?? '';
      debugPrint("🔥 USER STATUS FROM API: ${data['status']}");
    } catch (e) {
      debugPrint('❌ Error fetching profile: $e');
      if (e is DioException) {
        debugPrint('Response: ${e.response?.data}');
      }
      Get.snackbar(
        'Error',
        'Failed to load profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String newFirstName,
    required String newLastName,
    required String newPhone,
  }) async {
    try {
      isSavingProfile.value = true;

      final response = await _dio.put(
        'profile',
        data: {
          'first_name': newFirstName.trim(),
          'last_name': newLastName.trim(),
          'phone': newPhone.trim().isEmpty ? null : newPhone.trim(),
        },
      );

      final user = response.data['user'] ?? {};
      firstName.value = user['first_name'] ?? newFirstName;
      lastName.value = user['last_name'] ?? newLastName;
      name.value = '${firstName.value} ${lastName.value}';
      phone.value = user['phone']?.toString() ?? newPhone;

      Get.back(); // close bottom sheet
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingProfile.value = false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'New password and confirmation do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isChangingPassword.value = true;

      await _dio.put(
        'profile/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      Get.back(); // close sheet
      Get.snackbar(
        'Success',
        'Password changed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data['message']?.toString() ??
          'Failed to change password';
      Get.snackbar(
        'Error',
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> deleteAccount({required String password}) async {
    {
      try {
        isDeletingAccount.value = true;

        await _dio.delete('profile', data: {'password': password});

        // Clear session and go to login
        await SessionManager.clearSession();

        if (Get.isRegistered<LoginController>()) {
          Get.find<LoginController>().clearFields();
        }

        Get.offAllNamed('/login');
      } catch (e) {
        debugPrint('❌ Error deleting account: $e');
        Get.snackbar(
          'Error',
          'Failed to delete account',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isDeleting.value = false;
      }
    }
  }
}
