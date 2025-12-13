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
  RxDouble total_usd_Income = 0.0.obs;
  RxDouble total_eur_Income = 0.0.obs;
  RxDouble total_lbp_Income = 0.0.obs;

  RxDouble total_usd_Expenses = 0.0.obs;
  RxDouble total_eur_Expenses = 0.0.obs;
  RxDouble total_lbp_Expenses = 0.0.obs;

  // Transaction history
  RxList<Map<String, dynamic>> walletTransactions =
      <Map<String, dynamic>>[].obs;

  final Dio _dio = DioClient().getInstance();

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

  // ---------------------------------------------------------------------------
  // CURRENCY HELPERS
  // ---------------------------------------------------------------------------

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

  // INCOME SELECTION
  double get selectedIncome {
    switch (selectedCurrency.value) {
      case 'EUR':
        return total_eur_Income.value;
      case 'LBP':
        return total_lbp_Income.value;
      default:
        return total_usd_Income.value;
    }
  }

  // EXPENSES SELECTION
  double get selectedExpenses {
    switch (selectedCurrency.value) {
      case 'EUR':
        return total_eur_Expenses.value;
      case 'LBP':
        return total_lbp_Expenses.value;
      default:
        return total_usd_Expenses.value;
    }
  }

  // Symbol for UI formatting
  String get selectedSymbol {
    switch (selectedCurrency.value) {
      case 'EUR':
        return '€';
      case 'LBP':
        return 'LL';
      default:
        return '\$';
    }
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  void changeCurrency(String code) {
    selectedCurrency.value = code;
  }

  // ---------------------------------------------------------------------------
  // FETCH WALLET DATA
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

      // --- Transactions ---
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
  // LOCAL UPDATE AFTER SEND / RECEIVE
  // ---------------------------------------------------------------------------

  void applyUpdatedBalances(Map<String, dynamic> balanceMap) {
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
    fetchWalletData();
  }

  // ---------------------------------------------------------------------------
  // ADD TRANSACTION + RECALCULATE
  // ---------------------------------------------------------------------------

  void addTransaction(Map<String, dynamic> tx) {
    walletTransactions.insert(0, tx);
    recalculateStats();
  }

  void recalculateStats() {
    double usdIncome = 0, eurIncome = 0, lbpIncome = 0;
    double usdExpenses = 0, eurExpenses = 0, lbpExpenses = 0;

    for (var tx in walletTransactions) {
      final amount = tx['amount'] ?? 0.0;
      final currency = tx['currency'] ?? 'USD';
      final type = tx['type'];

      if (type == 'credit') {
        if (currency == 'USD') usdIncome += amount;
        if (currency == 'EUR') eurIncome += amount;
        if (currency == 'LBP') lbpIncome += amount;
      } else if (type == 'debit') {
        if (currency == 'USD') usdExpenses += amount;
        if (currency == 'EUR') eurExpenses += amount;
        if (currency == 'LBP') lbpExpenses += amount;
      }
    }

    total_usd_Income.value = usdIncome;
    total_eur_Income.value = eurIncome;
    total_lbp_Income.value = lbpIncome;

    total_usd_Expenses.value = usdExpenses;
    total_eur_Expenses.value = eurExpenses;
    total_lbp_Expenses.value = lbpExpenses;
  }
}
