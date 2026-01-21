  import 'package:cashpilot/Core/Network/TransactionServiceDio.dart';
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

    // Stats (COME FROM BACKEND ONLY ✅)
    RxDouble total_usd_Income = 0.0.obs;
    RxDouble total_eur_Income = 0.0.obs;
    RxDouble total_lbp_Income = 0.0.obs;

    RxDouble total_usd_Expenses = 0.0.obs;
    RxDouble total_eur_Expenses = 0.0.obs;
    RxDouble total_lbp_Expenses = 0.0.obs;

    // Recent transactions list
    RxList<Map<String, dynamic>> walletTransactions =
        <Map<String, dynamic>>[].obs;

    final Dio _dio = DioClient().getInstance();

    // ---------------------------------------------------------------------------
    // LIFECYCLE
    // ---------------------------------------------------------------------------

    @override
    void onInit() {
      super.onInit();
      refreshAll(); // ✅ one call loads everything
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

    /// ✅ Call this after ANY action (send / exchange / cash pickup / receive)
    Future<void> refreshAll() async {
      await fetchWalletData(); // includes balances + stats + recent tx from backend
    }

    // ---------------------------------------------------------------------------
    // FETCH WALLET DATA (SOURCE OF TRUTH ✅)
    // ---------------------------------------------------------------------------

    Future<void> fetchWalletData() async {
      try {
        isLoading.value = true;

        final Response response = await _dio.get('wallet');
        final data = response.data ?? {};

        // --- Balances ---
        final balances = data['currency_balances'] ?? {};

        usdBalance.value = double.tryParse('${balances['USD'] ?? 0}') ?? 0.0;
        eurBalance.value = double.tryParse('${balances['EUR'] ?? 0}') ?? 0.0;
        lbpBalance.value = double.tryParse('${balances['LBP'] ?? 0}') ?? 0.0;

        // --- Default currency ---
        if (data['default_currency'] != null) {
          selectedCurrency.value = data['default_currency'].toString();
        }

        // --- Stats (income/expenses) ---
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

        // --- Recent Transactions ---
        final List<dynamic> txList =
            (data['transactions'] ?? []) as List<dynamic>;

        walletTransactions.assignAll(
          txList.map<Map<String, dynamic>>((t) {
            return {
              'id': t['id'],
              'title': t['title'] ?? '',
              'amount': double.tryParse('${t['amount'] ?? 0}') ?? 0.0,
              'currency': t['currency'] ?? 'USD',
              'type': t['type'] ?? 'debit',
              'category': t['category'] ?? 'transfer',
              'date': t['date'] ?? '',
              'transacted_at': t['transacted_at'], // keep if backend sends it
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
    // OPTIONAL: FETCH TRANSACTIONS ONLY
    // ---------------------------------------------------------------------------
    // Use this ONLY if you have a separate endpoint for transactions.
    // But DO NOT use it to compute stats.
    // ---------------------------------------------------------------------------

    Future<void> fetchTransactions() async {
      try {
        final response = await TransactionService.fetchTransactions();
        final List<dynamic> txList = response['transactions'] ?? [];

        walletTransactions.assignAll(
          txList.map<Map<String, dynamic>>((t) {
            return {
              'id': t['id'],
              'title': t['title'] ?? '',
              'amount': double.tryParse('${t['amount'] ?? 0}') ?? 0.0,
              'currency': t['currency'] ?? 'USD',
              'type': t['type'] ?? 'debit',
              'category': t['category'] ?? 'transfer',
              'date': t['transacted_at']?.toString().substring(0, 10) ?? '',
              'transacted_at': t['transacted_at'],
            };
          }).toList(),
        );
      } catch (e) {
        print('❌ fetchTransactions error: $e');
      }
    }
  }
