import 'package:cashpilot/Controllers/NotificationController.dart';
import 'package:cashpilot/Core/Storage/SessionManager.dart';
import 'package:cashpilot/Controllers/LoginController.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:dio/dio.dart';

class HomeController extends GetxController {
  void _initFirebaseForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null) {
        // 🔔 Show in-app alert (foreground)
        Get.snackbar(
          notification.title ?? 'Notification',
          notification.body ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1E88E5),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }

      // // 🔄 Optional but recommended: refresh notifications list
      // if (Get.isRegistered<NotificationController>()) {
      //   Get.find<NotificationController>().fetchNotifications();
      // }
    });
  }

  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  var userName = ''.obs;
  var walletBalance = 0.0.obs;
  var isLoading = false.obs;
  var isBalanceVisible = true.obs;

  // Currency balances
  var usdBalance = 0.0.obs;
  var euroBalance = 0.0.obs;
  var lbpBalance = 0.0.obs;
  var selectedCurrency = 'USD'.obs;

  // Income and Expenses
  var total_usd_Income = 0.0.obs;
  var total_eur_Income = 0.0.obs;
  var total_lbp_Income = 0.0.obs;
  var total_usd_Expenses = 0.0.obs;
  var total_eur_Expenses = 0.0.obs;
  var total_lbp_Expenses = 0.0.obs;

  // Example lists
  var quickActions = [
    {'label': 'Send Money', 'icon': 'send'},
    {'label': 'Pay Bills', 'icon': 'receipt'},
    {'label': 'Add Money', 'icon': 'account_balance_wallet'},
  ];

  var services = [
    {'name': 'Telecome', 'icon': 'smartphone'},
    {'name': 'Internet', 'icon': 'wifi'},
    {'name': 'Student', 'icon': 'school'},
    {'name': 'Electricity', 'icon': 'bolt'},
    {'name': 'Water', 'icon': 'water'},
    {'name': 'Government', 'icon': 'account_balance'},
  ].obs;

  var recentTransactions = <Map<String, dynamic>>[].obs;

  //account status
  var accountStatus = 'pending'.obs;

  final _dio = DioClient().getInstance();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    _initFirebaseForegroundListener();
  }

  // @override
  // void onReady() {
  //   super.onReady();

  //   fetchDashboardData();
  // }

  // Helper to get current balance based on selected currency
  double get currentBalance {
    switch (selectedCurrency.value) {
      case 'EUR':
        return euroBalance.value;
      case 'LBP':
        return lbpBalance.value;
      case 'USD':
      default:
        return usdBalance.value;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // Fetch dashboard data
      Response response = await _dio.get('dashboard');

      // Example expected JSON:
      // {
      //   "user": {"name": "Mohammad"},
      //   "wallet": {
      //     "currency_balances": {
      //       "USD": 250.75,
      //       "EUR": 230.50,
      //       "LBP": 22437500
      //     },
      //     "default_currency": "USD",
      //     "stats": {
      //       "income": 1500.00,
      //       "expenses": 850.25
      //     }
      //   },
      //   "recent_transactions": [
      //      {"title": "Touch Recharge", "amount": -20.0, "date": "2025-11-21", "type": "debit"},
      //      ...
      //   ]
      // }

      final data = response.data;

      // User info
      // User info
      final user = data['user'] ?? {};

      userName.value = user['name'] ?? 'User';
      accountStatus.value = user['account_status'] ?? 'pending';

      // Wallet balances
      final wallet = data['wallet'] ?? {};
      final balances = wallet['currency_balances'] ?? {};

      usdBalance.value = double.tryParse('${balances['USD'] ?? 0}') ?? 0.0;
      euroBalance.value = double.tryParse('${balances['EUR'] ?? 0}') ?? 0.0;
      lbpBalance.value = double.tryParse('${balances['LBP'] ?? 0}') ?? 0.0;

      // Set default currency
      if (wallet['default_currency'] != null) {
        selectedCurrency.value = wallet['default_currency'];
      }

      // Stats
      final stats = wallet['stats'] ?? {};
      final income = stats['income'] ?? {};
      final expenses = stats['expenses'] ?? {};

      total_usd_Income.value = double.tryParse('${income['USD'] ?? 0}') ?? 0.0;
      total_eur_Income.value = double.tryParse('${income['EUR'] ?? 0}') ?? 0.0;
      total_lbp_Income.value = double.tryParse('${income['LBP'] ?? 0}') ?? 0.0;

      total_usd_Expenses.value =
          double.tryParse('${expenses['USD'] ?? 0}') ?? 0.0;
      total_eur_Expenses.value =
          double.tryParse('${expenses['EUR'] ?? 0}') ?? 0.0;
      total_lbp_Expenses.value =
          double.tryParse('${expenses['LBP'] ?? 0}') ?? 0.0;

      // Keep backward compatibility with old API
      walletBalance.value = currentBalance;

      // Recent transactions
      recentTransactions.assignAll(
        List<Map<String, dynamic>>.from(data['recent_transactions'] ?? []),
      );
    } catch (e) {
      print('Error fetching dashboard: $e');
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final token = await SessionManager.getToken();
      final dio = DioClient().getInstance();

      if (token != null) {
        await dio.post(
          'logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // ignore network errors on logout
    } finally {
      await SessionManager.clearSession();

      // ✅ CLEAR LOGIN FIELDS BEFORE NAVIGATING BACK
      if (Get.isRegistered<LoginController>()) {
        Get.find<LoginController>().clearFields();
      }

      Get.offAllNamed('/login');
    }
  }
}
