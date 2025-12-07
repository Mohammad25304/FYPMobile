import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class SendMoneyController extends GetxController {
  // Text controllers
  final amountController = TextEditingController();
  final recipientEmailController = TextEditingController();
  final recipientNameController = TextEditingController();
  final recipientPhoneController = TextEditingController();
  final noteController = TextEditingController();

  // Observables
  var selectedCurrency = 'USD'.obs;
  var amount = 0.0.obs;
  var isSending = false.obs;
  var lastTransactionId = ''.obs;
  var isSharing = false.obs;

  // Wallet controller
  final walletController = Get.find<WalletController>();

  // Dio
  final Dio _dio = DioClient().getInstance();

  // Get balances from wallet
  double get usdBalance => walletController.usdBalance.value;
  double get eurBalance => walletController.eurBalance.value;
  double get lbpBalance => walletController.lbpBalance.value;

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

  bool get canSend {
    return amount.value > 0 &&
        amount.value <= availableBalance &&
        recipientEmailController.text.isNotEmpty &&
        !isSending.value;
  }

  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  void updateAmount(String value) {
    amount.value = double.tryParse(value) ?? 0.0;
  }

  void setQuickAmount(String value) {
    amountController.text = value;
    amount.value = double.parse(value);
  }

  double calculateFee() => amount.value * 0.01;

  // ==============================
  // SEND MONEY API CALL
  // ==============================
  Future<void> sendMoney() async {
    if (!canSend) return;

    isSending.value = true;

    try {
      if (!_isValidEmail(recipientEmailController.text)) {
        Get.snackbar(
          "Invalid Email",
          "Please enter a valid email address",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isSending.value = false;
        return;
      }

      final response = await _dio.post(
        "send-money",
        data: {
          "receiver_email": recipientEmailController.text,
          "amount": amount.value,
          "currency": selectedCurrency.value,
          "note": noteController.text.isEmpty ? null : noteController.text,
        },
      );

      debugPrint("🔥 SEND MONEY RESPONSE: ${response.data}");

      // Save transaction ID
      if (response.data["transaction_id"] != null) {
        lastTransactionId.value = response.data["transaction_id"].toString();
      }

      // UPDATE WALLET BALANCES (FIXED)
      if (response.data["sender_balance"] != null) {
        final b = response.data["sender_balance"];

        if (b["balance_usd"] != null) {
          walletController.usdBalance.value =
              double.tryParse(b["balance_usd"].toString()) ??
              walletController.usdBalance.value;
        }
        if (b["balance_eur"] != null) {
          walletController.eurBalance.value =
              double.tryParse(b["balance_eur"].toString()) ??
              walletController.eurBalance.value;
        }
        if (b["balance_lbp"] != null) {
          walletController.lbpBalance.value =
              double.tryParse(b["balance_lbp"].toString()) ??
              walletController.lbpBalance.value;
        }
      }

      // Refresh wallet data to ensure everything is in sync
      await walletController.fetchWalletData();

      // Add to local history
      walletController.walletTransactions.insert(0, {
        "title":
            "Sent to ${recipientNameController.text.isNotEmpty ? recipientNameController.text : recipientEmailController.text}",
        "amount": amount.value,
        "type": "debit",
        "date": _getCurrentDate(),
        "currency": selectedCurrency.value,
      });

      // Success popup
      _showSuccessDialog();
    } catch (e) {
      debugPrint("❌ Send Money Error: $e");

      Get.snackbar(
        "Error",
        e is DioException
            ? e.response?.data["message"] ?? "Failed to send money"
            : "Failed to send money.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  // ==============================
  // SUCCESS POPUP
  // ==============================
  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
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
                "Money Sent Successfully!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "You sent $currencySymbol${amount.value.toStringAsFixed(2)} to ${recipientNameController.text.isNotEmpty ? recipientNameController.text : recipientEmailController.text}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _showShareDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Share Receipt"),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () {
                  _clearAllFields();
                  Get.back(); // close dialog
                  Get.back(); // back to wallet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Back to Wallet",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ==============================
  // SHARE METHODS POPUP
  // ==============================
  void _showShareDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Share Transaction Receipt",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),

                _shareButton(
                  "email",
                  Icons.email_outlined,
                  "Email",
                  "Send via Email",
                ),
                const SizedBox(height: 12),

                _shareButton("sms", Icons.sms_outlined, "SMS", "Send via SMS"),
                const SizedBox(height: 12),

                _shareButton(
                  "whatsapp",
                  Icons.chat_bubble_outline_rounded,
                  "WhatsApp",
                  "Send via WhatsApp",
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    _clearAllFields();
                    Get.back(); // close share popup
                    Get.back(); // close success popup
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Skip",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ==============================
  // SHARE API CALL
  // ==============================
  Future<void> shareTransaction(String method) async {
    if (lastTransactionId.value.isEmpty) return;

    isSharing.value = true;

    try {
      final response = await _dio.post(
        "transactions/share",
        data: {
          "transaction_id": lastTransactionId.value,
          "method": method,
          "recipient": _getShareRecipient(method),
        },
      );

      debugPrint("🔥 SHARE RESPONSE: ${response.data}");

      Get.snackbar(
        "Success",
        "Receipt shared via $method",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(seconds: 1), () {
        _clearAllFields();
        Get.back(); // close share popup
        Get.back(); // close success popup
      });
    } catch (e) {
      debugPrint("❌ Share Transaction Error: $e");

      Get.snackbar(
        "Error",
        "Failed to share receipt",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSharing.value = false;
    }
  }

  // Build each share option button
  Widget _shareButton(
    String method,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => shareTransaction(method),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // HELPERS
  // ==============================
  String _getShareRecipient(String method) {
    if (method == "email") return recipientEmailController.text;
    return recipientPhoneController.text;
  }

  void _clearAllFields() {
    amountController.clear();
    recipientEmailController.clear();
    recipientNameController.clear();
    recipientPhoneController.clear();
    noteController.clear();
    amount.value = 0.0;
    lastTransactionId.value = "";
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  @override
  void onClose() {
    amountController.dispose();
    recipientEmailController.dispose();
    recipientNameController.dispose();
    recipientPhoneController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
