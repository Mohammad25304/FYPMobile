import 'package:get/get.dart' hide Response;
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:dio/dio.dart';

class WalletController extends GetxController {
  // --- UI State ---
  RxBool isLoading = false.obs;

  // Balances per currency
  RxDouble usdBalance = 0.0.obs;
  RxDouble eurBalance = 0.0.obs;
  RxDouble lbpBalance = 0.0.obs;

  // Selected currency and helpers
  RxString selectedCurrency = 'USD'.obs;

  String get currencySymbol {
    switch (selectedCurrency.value) {
      case 'EUR':
        return '€';
      case 'LBP':
        return 'LL';
      case 'USD':
      default:
        return '\$';
    }
  }

  String get currencyName {
    switch (selectedCurrency.value) {
      case 'EUR':
        return 'Euro';
      case 'LBP':
        return 'Lebanese Pound';
      case 'USD':
      default:
        return 'US Dollar';
    }
  }

  double get currentBalance {
    switch (selectedCurrency.value) {
      case 'EUR':
        return eurBalance.value;
      case 'LBP':
        return lbpBalance.value;
      case 'USD':
      default:
        return usdBalance.value;
    }
  }

  // Stats
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpenses = 0.0.obs;

  // Transactions list for the UI
  RxList<Map<String, dynamic>> walletTransactions =
      <Map<String, dynamic>>[].obs;

  final Dio _dio = DioClient().getInstance();

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

  void changeCurrency(String code) {
    selectedCurrency.value = code;
  }

  Future<void> fetchWalletData() async {
    try {
      isLoading.value = true;

      final Response response = await _dio.get(
        'wallet', // full URL = http://192.168.1.67/api/wallet
        // If you need token manually:
        // options: Options(headers: {'Authorization': 'Bearer YOUR_TOKEN'}),
      );

      final data = response.data;

      // 1) Balances
      final balances = data['currency_balances'] ?? {};
      usdBalance.value = double.tryParse('${balances['USD'] ?? 0}') ?? 0.0;
      eurBalance.value = double.tryParse('${balances['EUR'] ?? 0}') ?? 0.0;
      lbpBalance.value = double.tryParse('${balances['LBP'] ?? 0}') ?? 0.0;

      // 2) Default currency (optional)
      if (data['default_currency'] != null) {
        selectedCurrency.value = data['default_currency'];
      }

      // 3) Stats
      final stats = data['stats'] ?? {};
      totalIncome.value = double.tryParse('${stats['income'] ?? 0}') ?? 0.0;
      totalExpenses.value = double.tryParse('${stats['expenses'] ?? 0}') ?? 0.0;

      // 4) Transactions
      final txList = data['transactions'] as List<dynamic>? ?? [];
      walletTransactions.assignAll(
        txList.map(
          (t) => {
            'title': t['title'] ?? '',
            'amount': double.tryParse('${t['amount'] ?? 0}') ?? 0.0,
            'type': t['type'] ?? 'debit',
            'date': t['date'] ?? '',
            'currency': t['currency'] ?? 'USD',
          },
        ),
      );
    } catch (e) {
      // You can improve this with better error handling
      Get.snackbar(
        'Wallet Error',
        'Failed to load wallet data',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Wallet API error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
