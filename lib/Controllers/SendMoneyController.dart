import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/WalletController.dart';

class SendMoneyController extends GetxController {
  // Text controllers
  final amountController = TextEditingController();
  final recipientController = TextEditingController();
  final noteController = TextEditingController();

  // Observables
  var selectedCurrency = 'USD'.obs;
  var amount = 0.0.obs;
  var isSending = false.obs;

  // Get wallet controller
  final walletController = Get.find<WalletController>();

  // Currency balances (from wallet)
  double get usdBalance => walletController.usdBalance.value;
  double get eurBalance => walletController.eurBalance.value;
  double get lbpBalance => walletController.lbpBalance.value;

  // Get available balance based on selected currency
  double get availableBalance {
    switch (selectedCurrency.value) {
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

  // Currency symbol
  String get currencySymbol {
    switch (selectedCurrency.value) {
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

  // Check if can send
  bool get canSend {
    return amount.value > 0 &&
        amount.value <= availableBalance &&
        recipientController.text.isNotEmpty &&
        !isSending.value;
  }

  // Select currency
  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
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

  // Select recipient
  void selectRecipient(String name) {
    recipientController.text = name;
  }

  // Calculate transaction fee (1% of amount)
  double calculateFee() {
    return amount.value * 0.01;
  }

  // Send money
  Future<void> sendMoney() async {
    if (!canSend) return;

    isSending.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final fee = calculateFee();
      final total = amount.value + fee;

      // Deduct from wallet balance
      switch (selectedCurrency.value) {
        case 'USD':
          walletController.usdBalance.value -= total;
          break;
        case 'EUR':
          walletController.eurBalance.value -= total;
          break;
        case 'LBP':
          walletController.lbpBalance.value -= total;
          break;
      }

      // Add transaction to wallet history
      walletController.walletTransactions.insert(0, {
        'title': 'Sent to ${recipientController.text}',
        'amount': amount.value,
        'type': 'debit',
        'date': _getCurrentDate(),
        'note': noteController.text.isEmpty ? null : noteController.text,
        'currency': selectedCurrency.value,
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
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
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
                  'Money Sent Successfully!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You sent $currencySymbol${amount.value.toStringAsFixed(2)} to ${recipientController.text}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
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
                      backgroundColor: const Color(0xFF1E88E5),
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
        'Failed to send money. Please try again.',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 14,
      );
    } finally {
      isSending.value = false;
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    amountController.dispose();
    recipientController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
