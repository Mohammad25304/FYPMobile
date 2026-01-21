import 'dart:io';
import 'dart:ui' as ui;

import 'package:cashpilot/Controllers/HomeController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SendMoneyController extends GetxController {
  // ======================
  // CONTROLLERS
  // ======================
  final amountController = TextEditingController();
  final recipientEmailController = TextEditingController();
  final recipientNameController = TextEditingController();
  final recipientPhoneController = TextEditingController();
  final noteController = TextEditingController();

  final homeController = Get.find<HomeController>();
  final walletController = Get.find<WalletController>();
  final Dio _dio = DioClient().getInstance();

  // ======================
  // STATE
  // ======================
  final selectedCurrency = 'USD'.obs;
  final amount = 0.0.obs;
  final recipientEmail = ''.obs;

  final fee = 0.0.obs;
  final total = 0.0.obs;

  final isFeeLoading = false.obs;
  final isSending = false.obs;
  final isSharing = false.obs;

  final lastTransactionId = ''.obs;

  // ======================
  // CONFIG
  // ======================
  static const String receiptBaseUrl = "https://cashpilot.app/receipt";

  // ======================
  // BALANCES
  // ======================
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

  // ======================
  // VALIDATION
  // ======================
  bool get canSend {
    return amount.value > 0 &&
        total.value <= availableBalance &&
        recipientEmail.value.isNotEmpty &&
        !isSending.value;
  }

  // ======================
  // INPUT HANDLERS
  // ======================
  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
    fetchFeePreview();
  }

  void updateRecipientEmail(String value) {
    recipientEmail.value = value;
  }

  void updateAmount(String value) {
    amount.value = double.tryParse(value) ?? 0.0;
    fetchFeePreview();
  }

  // ======================
  // 🔐 FEE PREVIEW (BACKEND)
  // ======================
  Future<void> fetchFeePreview() async {
    if (amount.value <= 0) {
      fee.value = 0;
      total.value = amount.value;
      return;
    }

    isFeeLoading.value = true;

    try {
      final response = await _dio.post(
        "fees/preview",
        data: {
          "context": "send_money",
          "currency": selectedCurrency.value,
          "amount": amount.value,
        },
      );

      fee.value = (response.data["fee"] ?? 0).toDouble();
      total.value = (response.data["total"] ?? amount.value).toDouble();
    } catch (_) {
      fee.value = 0;
      total.value = amount.value;
    } finally {
      isFeeLoading.value = false;
    }
  }

  double calculateFee() => fee.value;

  // ======================
  // SEND MONEY
  // ======================
  Future<void> sendMoney() async {
    if (!canSend) return;

    if (!_isValidEmail(recipientEmailController.text)) {
      _error("Invalid email address");
      return;
    }

    isSending.value = true;

    try {
      final response = await _dio.post(
        "send-money",
        data: {
          "receiver_email": recipientEmailController.text,
          "amount": amount.value,
          "currency": selectedCurrency.value,
          "note": noteController.text.isEmpty ? null : noteController.text,
        },
      );

      lastTransactionId.value = response.data["transaction_id"].toString();

      await walletController.refreshAll();
      await homeController.fetchDashboardData();

      _showSuccessDialog();
    } catch (e) {
      _error(
        e is DioException
            ? e.response?.data["message"] ?? "Failed to send money"
            : "Failed to send money",
      );
    } finally {
      isSending.value = false;
    }
  }

  // ======================
  // SUCCESS UI
  // ======================
  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFEEF2F7)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Animation
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
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

                  // Title
                  const Text(
                    "Money Sent Successfully",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "Transaction completed",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Transaction Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E88E5).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Amount Sent",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "$currencySymbol${amount.value.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedCurrency.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Transaction ID
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xA010B981),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          size: 20,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "ID: ${lastTransactionId.value}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Copy Transaction ID Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: lastTransactionId.value),
                        );
                        Get.snackbar(
                          "",
                          "Transaction ID copied to clipboard",
                          backgroundColor: const Color(0xFF10B981),
                          colorText: Colors.white,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          borderRadius: 16,
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.content_copy_rounded, size: 20),
                      label: const Text(
                        "Copy Transaction ID",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showShareDialog();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF1E88E5),
                          width: 2,
                        ),
                      ),
                      icon: const Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: Color(0xFF1E88E5),
                      ),
                      label: const Text(
                        "Share Receipt",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Back to Wallet",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ======================
  // SHARE OPTIONS
  // ======================
  void _showShareDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFEEF2F7)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Share Receipt",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Choose how to send this receipt",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Share Options
                  _shareOptionButton(
                    "email",
                    Icons.email_rounded,
                    "Email",
                    "Send directly to receiver's email",
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 12),

                  _shareOptionButton(
                    "pdf",
                    Icons.picture_as_pdf_rounded,
                    "PDF Document",
                    "Download as PDF file",
                    const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 12),

                  _shareOptionButton(
                    "image",
                    Icons.image_rounded,
                    "Image",
                    "Share as PNG image",
                    const Color(0xFF8B5CF6),
                  ),

                  const SizedBox(height: 20),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shareOptionButton(
    String type,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Obx(
      () => GestureDetector(
        onTap: isSharing.value
            ? null
            : () async {
                isSharing.value = true;

                if (type == "email") {
                  await shareViaEmail();
                } else if (type == "pdf") {
                  await sharePdfReceipt();
                } else {
                  await shareImageReceipt();
                }

                isSharing.value = false;
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSharing.value
                  ? color.withOpacity(0.3)
                  : Colors.grey[200]!,
              width: 2,
            ),
            boxShadow: [
              if (!isSharing.value)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSharing.value)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1E88E5),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================
  // EMAIL SHARE (AUTO-FILLED RECEIVER)
  // ======================
  Future<void> shareViaEmail() async {
    if (lastTransactionId.value.isEmpty) return;

    final verificationUrl = "$receiptBaseUrl/${lastTransactionId.value}";

    final body =
        '''
CashPilot Transaction Receipt

Transaction ID: ${lastTransactionId.value}
Amount: $currencySymbol${amount.value.toStringAsFixed(2)}
Fee: $currencySymbol${fee.value.toStringAsFixed(2)}
Total: $currencySymbol${total.value.toStringAsFixed(2)}
Currency: ${selectedCurrency.value}
Date: ${DateTime.now()}

Verify this receipt:
$verificationUrl

Thank you for using CashPilot 💙
''';

    final uri = Uri(
      scheme: 'mailto',
      path: recipientEmailController.text, // 🔥 AUTO-FILLED RECEIVER
      queryParameters: {
        'subject': 'CashPilot Transaction Receipt',
        'body': body,
      },
    );

    if (!await canLaunchUrl(uri)) {
      _error("Cannot open email app");
      return;
    }

    await _logShare("email");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ======================
  // PDF RECEIPT
  // ======================
  Future<File> _generatePdfReceipt() async {
    final verificationUrl = "$receiptBaseUrl/${lastTransactionId.value}";

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "CashPilot Transaction Receipt",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Transaction ID: ${lastTransactionId.value}"),
            pw.Text(
              "Amount: $currencySymbol${amount.value.toStringAsFixed(2)}",
            ),
            pw.Text("Fee: $currencySymbol${fee.value.toStringAsFixed(2)}"),
            pw.Text("Total: $currencySymbol${total.value.toStringAsFixed(2)}"),
            pw.Text("Currency: ${selectedCurrency.value}"),
            pw.Text("Recipient: ${recipientEmailController.text}"),
            pw.Text("Date: ${DateTime.now()}"),
            pw.SizedBox(height: 16),
            pw.Text("Verify receipt:"),
            pw.Text(verificationUrl),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/CashPilot_Receipt_${lastTransactionId.value}.pdf",
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> sharePdfReceipt() async {
    try {
      final file = await _generatePdfReceipt();
      await _logShare("pdf");

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "CashPilot Transaction Receipt");
    } catch (_) {
      _error("Failed to share PDF receipt");
    }
  }

  // ======================
  // IMAGE RECEIPT
  // ======================
  Future<File> _generateImageReceipt() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const width = 1080.0;
    const height = 760.0;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.white,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double y = 40;

    void draw(String text, double size, FontWeight weight) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: Colors.black,
        ),
      );
      textPainter.layout(maxWidth: width - 80);
      textPainter.paint(canvas, Offset(40, y));
      y += textPainter.height + 16;
    }

    final verificationUrl = "$receiptBaseUrl/${lastTransactionId.value}";

    draw("CashPilot Transaction Receipt", 30, FontWeight.bold);
    draw("Transaction ID: ${lastTransactionId.value}", 18, FontWeight.normal);
    draw(
      "Amount: $currencySymbol${amount.value.toStringAsFixed(2)}",
      18,
      FontWeight.normal,
    );
    draw(
      "Fee: $currencySymbol${fee.value.toStringAsFixed(2)}",
      18,
      FontWeight.normal,
    );
    draw(
      "Total: $currencySymbol${total.value.toStringAsFixed(2)}",
      20,
      FontWeight.bold,
    );
    draw("Currency: ${selectedCurrency.value}", 18, FontWeight.normal);
    draw("Recipient: ${recipientEmailController.text}", 18, FontWeight.normal);
    draw("Verify: $verificationUrl", 16, FontWeight.normal);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/CashPilot_Receipt_${lastTransactionId.value}.png",
    );

    await file.writeAsBytes(bytes!.buffer.asUint8List());
    return file;
  }

  Future<void> shareImageReceipt() async {
    try {
      final file = await _generateImageReceipt();
      await _logShare("image");

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "CashPilot Transaction Receipt");
    } catch (_) {
      _error("Failed to share image receipt");
    }
  }

  // ======================
  // BACKEND SHARE LOG
  // ======================
  Future<void> _logShare(String method) async {
    try {
      await _dio.post(
        "transactions/share",
        data: {
          "transaction_id": lastTransactionId.value,
          "method": method,
          "recipient": recipientEmailController.text,
        },
      );
    } catch (_) {}
  }

  // ======================
  // HELPERS
  // ======================
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  void _error(String msg) {
    Get.snackbar(
      "Error",
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
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
