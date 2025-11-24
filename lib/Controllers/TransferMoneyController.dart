import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/WalletController.dart';

class TransferMoneyController extends GetxController {
  // Text controllers
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  // Observables
  var fromCurrency = 'USD'.obs;
  var toCurrency = 'EUR'.obs;
  var amount = 0.0.obs;
  var isTransferring = false.obs;

  // Get wallet controller
  final walletController = Get.find<WalletController>();

  // Currency balances (from wallet)
  double get usdBalance => walletController.usdBalance.value;
  double get eurBalance => walletController.eurBalance.value;
  double get lbpBalance => walletController.lbpBalance.value;

  // Exchange rates (example rates - in real app, fetch from API)
  final Map<String, Map<String, double>> exchangeRates = {
    'USD': {'EUR': 0.92, 'LBP': 89500.0},
    'EUR': {'USD': 1.09, 'LBP': 97350.0},
    'LBP': {'USD': 0.0000112, 'EUR': 0.0000103},
  };

  // Get balance based on currency
  double get fromBalance {
    switch (fromCurrency.value) {
      case 'USD':
        return usdBalance;
      case 'EUR':
        return eurBalance;
      case 'LBP':
        return lbpBalance;
      default:
        return usdBalance;
    }
  }

  double get toBalance {
    switch (toCurrency.value) {
      case 'USD':
        return usdBalance;
      case 'EUR':
        return eurBalance;
      case 'LBP':
        return lbpBalance;
      default:
        return eurBalance;
    }
  }

  // Check if can transfer
  bool get canTransfer {
    return amount.value > 0 &&
        amount.value <= fromBalance &&
        fromCurrency.value != toCurrency.value &&
        !isTransferring.value;
  }

  // Update amount
  void updateAmount(String value) {
    amount.value = double.tryParse(value) ?? 0.0;
  }

  // Set quick amount
  void setQuickAmount(String value) {
    amountController.text = value;
    amount.value = double.parse(value);
  }

  // Set all available balance
  void setAllAmount() {
    final balance = fromBalance;
    amountController.text = balance.toStringAsFixed(2);
    amount.value = balance;
  }

  // Set from currency
  void setFromCurrency(String currency) {
    if (currency != toCurrency.value) {
      fromCurrency.value = currency;
    } else {
      // Swap if trying to select the same as destination
      swapCurrencies();
    }
  }

  // Set to currency
  void setToCurrency(String currency) {
    if (currency != fromCurrency.value) {
      toCurrency.value = currency;
    } else {
      // Swap if trying to select the same as source
      swapCurrencies();
    }
  }

  // Swap currencies
  void swapCurrencies() {
    final temp = fromCurrency.value;
    fromCurrency.value = toCurrency.value;
    toCurrency.value = temp;
  }

  // Get exchange rate
  double getExchangeRate() {
    if (fromCurrency.value == toCurrency.value) return 1.0;
    return exchangeRates[fromCurrency.value]?[toCurrency.value] ?? 1.0;
  }

  // Get converted amount
  double getConvertedAmount() {
    if (amount.value == 0) return 0.0;
    return amount.value * getExchangeRate();
  }

  // Transfer money
  Future<void> transferMoney() async {
    if (!canTransfer) return;

    isTransferring.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final convertedAmount = getConvertedAmount();

      // Deduct from source currency
      switch (fromCurrency.value) {
        case 'USD':
          walletController.usdBalance.value -= amount.value;
          break;
        case 'EUR':
          walletController.eurBalance.value -= amount.value;
          break;
        case 'LBP':
          walletController.lbpBalance.value -= amount.value;
          break;
      }

      // Add to destination currency
      switch (toCurrency.value) {
        case 'USD':
          walletController.usdBalance.value += convertedAmount;
          break;
        case 'EUR':
          walletController.eurBalance.value += convertedAmount;
          break;
        case 'LBP':
          walletController.lbpBalance.value += convertedAmount;
          break;
      }

      // Add transaction to wallet history
      walletController.walletTransactions.insert(0, {
        'title': 'Transfer ${fromCurrency.value} to ${toCurrency.value}',
        'amount': amount.value,
        'type': 'transfer',
        'date': _getCurrentDate(),
        'note': noteController.text.isEmpty ? null : noteController.text,
        'fromCurrency': fromCurrency.value,
        'toCurrency': toCurrency.value,
        'convertedAmount': convertedAmount,
      });

      // Show success dialog
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Transfer Successful!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You transferred ${_getCurrencySymbol(fromCurrency.value)}${amount.value.toStringAsFixed(2)} to ${toCurrency.value}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Received: ${_getCurrencySymbol(toCurrency.value)}${_formatBalance(convertedAmount, toCurrency.value)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.back(); // Go back to wallet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Back to Wallet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      // Show error
      Get.snackbar(
        'Error',
        'Failed to transfer money. Please try again.',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 14,
      );
    } finally {
      isTransferring.value = false;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'LBP':
        return 'LL';
      default:
        return '\$';
    }
  }

  String _formatBalance(double balance, String currency) {
    if (currency == 'LBP') {
      return balance
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return balance.toStringAsFixed(2);
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
