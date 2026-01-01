import 'package:cashpilot/Core/Network/TransferService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/WalletController.dart';

class TransferMoneyController extends GetxController {
  // Text controllers
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  // Observables
  final fromCurrency = 'USD'.obs;
  final toCurrency = 'EUR'.obs;
  final amount = 0.0.obs;
  final isTransferring = false.obs;

  // Wallet controller
  final WalletController walletController = Get.find<WalletController>();

  // Wallet balances
  double get usdBalance => walletController.usdBalance.value;
  double get eurBalance => walletController.eurBalance.value;
  double get lbpBalance => walletController.lbpBalance.value;

  // Balance getters
  double get fromBalance {
    switch (fromCurrency.value) {
      case 'USD':
        return usdBalance;
      case 'EUR':
        return eurBalance;
      case 'LBP':
        return lbpBalance;
      default:
        return 0.0;
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
        return 0.0;
    }
  }

  // Can transfer
  bool get canTransfer =>
      amount.value > 0 &&
      amount.value <= fromBalance &&
      fromCurrency.value != toCurrency.value &&
      !isTransferring.value;

  // Amount handling
  void updateAmount(String value) {
    amount.value = double.tryParse(value) ?? 0.0;
  }

  void setQuickAmount(String value) {
    amountController.text = value;
    amount.value = double.tryParse(value) ?? 0.0;
  }

  void setAllAmount() {
    amountController.text = fromBalance.toStringAsFixed(2);
    amount.value = fromBalance;
  }

  // Currency selection
  void setFromCurrency(String currency) {
    if (currency == toCurrency.value) {
      swapCurrencies();
    } else {
      fromCurrency.value = currency;
    }
  }

  void setToCurrency(String currency) {
    if (currency == fromCurrency.value) {
      swapCurrencies();
    } else {
      toCurrency.value = currency;
    }
  }

  void swapCurrencies() {
    final temp = fromCurrency.value;
    fromCurrency.value = toCurrency.value;
    toCurrency.value = temp;
  }

  // =============================
  // API CALL (Backend decides fee)
  // =============================
  Future<void> transferMoney() async {
    if (!canTransfer) return;

    isTransferring.value = true;

    try {
      await TransferService.transfer(
        fromCurrency: fromCurrency.value,
        toCurrency: toCurrency.value,
        amount: amount.value,
        note: noteController.text.isEmpty ? null : noteController.text,
      );

      // Backend is source of truth
      await walletController.fetchWalletData();

      _showSuccessDialog();
    } catch (e) {
      Get.snackbar('Transfer Failed', 'Something went wrong');
    } finally {
      isTransferring.value = false;
    }
  }

  // Success dialog
  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Transfer Successful'),
        content: Text(
          '${amount.value.toStringAsFixed(2)} ${fromCurrency.value} transferred to ${toCurrency.value}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              amountController.clear();
              noteController.clear();
              amount.value = 0.0;
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }

  // =============================
  // UI PREVIEW ONLY (NO BUSINESS)
  // =============================
  // Backend exchange & fees are final

  final Map<String, Map<String, double>> _previewRates = {
    'USD': {'EUR': 0.92, 'LBP': 89500},
    'EUR': {'USD': 1.09, 'LBP': 97350},
    'LBP': {'USD': 0.0000112, 'EUR': 0.0000103},
  };

  double getExchangeRate() {
    if (fromCurrency.value == toCurrency.value) return 1.0;
    return _previewRates[fromCurrency.value]?[toCurrency.value] ?? 1.0;
  }

  double getConvertedAmount() {
    return amount.value * getExchangeRate();
  }
}
