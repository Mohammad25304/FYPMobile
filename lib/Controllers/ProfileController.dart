import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:cashpilot/Core/Storage/SessionManager.dart';
import 'package:cashpilot/Controllers/LoginController.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final Dio _dio = DioClient().getInstance();
  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  var isSavingProfile = false.obs;
  var isChangingPassword = false.obs;
  var isDeleting = false.obs;
  var isDeletingAccount = false.obs;
  var isUploadingAvatar = false.obs;

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

  Future<void> uploadAvatar(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      isUploadingAvatar.value = true;

      // Create multipart request
      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          pickedFile.path,
          filename: 'avatar.jpg',
        ),
      });

      final response = await _dio.post(
        'profile/avatar',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data', // ✅ ADD THIS
          },
        ),
      );

      avatarUrl.value = response.data['avatar_url'] ?? '';

      Get.snackbar(
        'Success',
        'Profile picture updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Error uploading avatar: $e');
      Get.snackbar(
        'Error',
        'Failed to upload profile picture',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFF1E88E5),
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Get.back();
                uploadAvatar(ImageSource.camera);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFF1E88E5),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Get.back();
                uploadAvatar(ImageSource.gallery);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
