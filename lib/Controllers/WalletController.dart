import 'package:get/get.dart';

class WalletController extends GetxController {
  RxDouble walletBalance = 1200.50.obs;
  // In WalletController
  var usdBalance = 2540.00.obs;
  var eurBalance = 1890.50.obs;
  var lbpBalance = 89500000.0.obs;

  var selectedCurrency = 'USD'.obs;

  RxList<Map<String, dynamic>> walletTransactions = [
    {
      'title': 'Payment Received',
      'amount': 250.00,
      'type': 'credit',
      'date': '2025-01-20',
    },
    {
      'title': 'Bill Payment',
      'amount': 75.40,
      'type': 'debit',
      'date': '2025-01-18',
    },
    {
      'title': 'Money Transfer',
      'amount': 110.00,
      'type': 'debit',
      'date': '2025-01-17',
    },
  ].obs;

  // Future API connection
  Future<void> fetchWalletData() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
