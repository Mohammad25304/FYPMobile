import 'package:cashpilot/Core/Storage/SessionManager.dart';
import 'package:get/get.dart' hide Response;
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:dio/dio.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  var userName = 'Mohammad'.obs;
  var walletBalance = 0.0.obs;
  var isLoading = false.obs;
  var isBalanceVisible = true.obs;
  var usdBalance = 0.0.obs;
  var euroBalance = 0.0.obs;
  var lbpBalance = 0.0.obs;
  var selectedCurrency = 'USD'.obs;
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

  final _dio = DioClient().getInstance();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // TODO: replace with your real endpoint
      Response response = await _dio.get('dashboard');

      // Example expected JSON:
      // {
      //   "user": {"name": "Mohammad"},
      //   "wallet": {"balance": 250.75},
      //   "recent_transactions": [
      //      {"title": "Touch Recharge", "amount": -20.0, "date": "2025-11-21", "type": "debit"},
      //      ...
      //   ]
      // }

      final data = response.data;
      userName.value = data['user']['name'] ?? 'User';
      walletBalance.value =
          double.tryParse(data['wallet']['balance'].toString()) ?? 0.0;
      recentTransactions.assignAll(
        List<Map<String, dynamic>>.from(data['recent_transactions'] ?? []),
      );
    } catch (e) {
      // For now just print, later you can show a snackbar
      print('Error fetching dashboard: $e');
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
      Get.offAllNamed('/login');
    }
  }
}
