import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class WalletController extends GetxController {
  // ---------------------------------------------------------------------------
  // OBSERVABLE STATE
  // ---------------------------------------------------------------------------

  RxBool isLoading = false.obs;

  // Currency balances
  RxDouble usdBalance = 0.0.obs;
  RxDouble eurBalance = 0.0.obs;
  RxDouble lbpBalance = 0.0.obs;

  // Selected currency
  RxString selectedCurrency = 'USD'.obs;

  // Stats
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpenses = 0.0.obs;

  // Transaction history
  RxList<Map<String, dynamic>> walletTransactions =
      <Map<String, dynamic>>[].obs;

  final Dio _dio = DioClient().getInstance();

  // ---------------------------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------------------------

  /// Returns symbol for selected currency
  String get currencySymbol {
    switch (selectedCurrency.value) {
      case 'EUR':
        return '€';
      case 'LBP':
        return 'LL';
      default:
        return '\$';
    }
  }

  /// Pretty currency name
  String get currencyName {
    switch (selectedCurrency.value) {
      case 'EUR':
        return 'Euro';
      case 'LBP':
        return 'Lebanese Pound';
      default:
        return 'US Dollar';
    }
  }

  /// Based on user-selected currency
  double get currentBalance {
    switch (selectedCurrency.value) {
      case 'EUR':
        return eurBalance.value;
      case 'LBP':
        return lbpBalance.value;
      default:
        return usdBalance.value;
    }
  }

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  void changeCurrency(String code) {
    selectedCurrency.value = code;
  }

  // ---------------------------------------------------------------------------
  // FETCH WALLET DATA FROM BACKEND
  // ---------------------------------------------------------------------------

  Future<void> fetchWalletData() async {
    try {
      isLoading.value = true;

      final Response response = await _dio.get('wallet');
      final data = response.data;

      // --- Balances ---
      final balances = data['currency_balances'] ?? {};

      usdBalance.value = double.tryParse('${balances['USD'] ?? 0}') ?? 0.0;

      eurBalance.value = double.tryParse('${balances['EUR'] ?? 0}') ?? 0.0;

      lbpBalance.value = double.tryParse('${balances['LBP'] ?? 0}') ?? 0.0;

      // --- Default currency ---
      if (data['default_currency'] != null) {
        selectedCurrency.value = data['default_currency'];
      }

      // --- Stats ---
      final stats = data['stats'] ?? {};
      totalIncome.value = double.tryParse('${stats['income'] ?? 0}') ?? 0.0;

      totalExpenses.value = double.tryParse('${stats['expenses'] ?? 0}') ?? 0.0;

      // --- Transactions History ---
      final txList = data['transactions'] as List<dynamic>? ?? [];

      walletTransactions.assignAll(
        txList.map((t) {
          return {
            'title': t['title'] ?? '',
            'amount': double.tryParse('${t['amount'] ?? 0}') ?? 0.0,
            'type': t['type'] ?? 'debit',
            'date': t['date'] ?? '',
            'currency': t['currency'] ?? 'USD',
          };
        }).toList(),
      );
    } catch (e) {
      print('⚠ fetchWalletData error: $e');
      if (e is DioException) {
        print('Status: ${e.response?.statusCode}');
        print('Details: ${e.response?.data}');
      }

      Get.snackbar(
        'Wallet Error',
        'Failed to load wallet data.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // METHOD TO UPDATE WALLET LOCALLY AFTER SEND / RECEIVE MONEY
  // ---------------------------------------------------------------------------

  void applyUpdatedBalances(Map<String, dynamic> balanceMap) {
    // Update balances locally first for immediate UI feedback
    if (balanceMap.containsKey('USD')) {
      usdBalance.value =
          double.tryParse('${balanceMap['USD']}') ?? usdBalance.value;
    }
    if (balanceMap.containsKey('EUR')) {
      eurBalance.value =
          double.tryParse('${balanceMap['EUR']}') ?? eurBalance.value;
    }
    if (balanceMap.containsKey('LBP')) {
      lbpBalance.value =
          double.tryParse('${balanceMap['LBP']}') ?? lbpBalance.value;
    }

    // Refresh everything from backend to stay in sync
    fetchWalletData();
  }

  // ---------------------------------------------------------------------------
  // ADD A TRANSACTION TO HISTORY (used by SendMoneyController)
  // ---------------------------------------------------------------------------

  void addTransaction(Map<String, dynamic> tx) {
    walletTransactions.insert(0, tx);
    recalculateStats();
  }

  // ---------------------------------------------------------------------------
  // RECALCULATE TOTAL INCOME & EXPENSES
  // ---------------------------------------------------------------------------

  void recalculateStats() {
    double income = 0.0;
    double expenses = 0.0;

    for (var tx in walletTransactions) {
      // Only count transactions in the selected currency
      if (tx['currency'] == selectedCurrency.value) {
        if (tx['type'] == 'credit') {
          income += tx['amount'];
        } else if (tx['type'] == 'debit') {
          expenses += tx['amount'];
        }
      }
    }

    totalIncome.value = income;
    totalExpenses.value = expenses;
  }
}
