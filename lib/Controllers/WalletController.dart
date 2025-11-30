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

      final Response response = await _dio.get('wallet');
      final data = response.data;

      final balances = data['currency_balances'] ?? {};
      usdBalance.value = double.tryParse('${balances['USD'] ?? 0}') ?? 0.0;
      eurBalance.value = double.tryParse('${balances['EUR'] ?? 0}') ?? 0.0;
      lbpBalance.value = double.tryParse('${balances['LBP'] ?? 0}') ?? 0.0;

      if (data['default_currency'] != null) {
        selectedCurrency.value = data['default_currency'];
      }

      final stats = data['stats'] ?? {};
      totalIncome.value = double.tryParse('${stats['income'] ?? 0}') ?? 0.0;
      totalExpenses.value = double.tryParse('${stats['expenses'] ?? 0}') ?? 0.0;

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
      print('Full error details: $e');
      print('Error type: ${e.runtimeType}');
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      Get.snackbar(
        'Wallet Error',
        'Failed to load wallet data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
