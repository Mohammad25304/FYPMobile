import 'dart:ui';

import 'package:cashpilot/Controllers/HomeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  var notificationsEnabled = true.obs;
  var darkModeEnabled = false.obs;
  var selectedCurrency = 'USD'.obs;
  var isDeletingAccount = false.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    // TODO: Save to backend or local storage
  }

  void toggleDarkMode(bool value) {
    darkModeEnabled.value = value;
    // TODO: Apply theme & persist
  }

  void changeCurrency(String value) {
    selectedCurrency.value = value;
    // TODO: Save preference
  }

  void logout() {
    // TODO: Clear session & redirect to login
  }
  Future<void> deleteAccount({required String password}) async {
    if (password.isEmpty) {
      Get.snackbar(
        'Error',
        'Password is required',
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0F172A),
      );
      return;
    }

    try {
      isDeletingAccount.value = true;

      // 🔴 CALL YOUR API HERE
      // example:
      // await DioClient.delete(
      //   '/profile',
      //   data: { 'password': password },
      // );

      Get.back(); // close bottom sheet

      Get.snackbar(
        'Account Deleted',
        'Your account has been permanently deleted',
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0F172A),
      );

      // logout after delete
      Get.find<HomeController>().logout();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid password',
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }
}
