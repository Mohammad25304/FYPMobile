import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Controllers/HomeController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CashPickupController extends GetxController {
  // =============================
  // TEXT CONTROLLERS
  // =============================
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();
  final receiverEmailController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  // =============================
  // STATE
  // =============================
  final selectedCurrency = 'USD'.obs;
  final amount = 0.0.obs;

  final fee = 0.0.obs;
  final total = 0.0.obs;

  final isFeeLoading = false.obs;
  final isSending = false.obs;
  final isSharing = false.obs;

  final receiverName = ''.obs;
  final receiverPhone = ''.obs;

  // Cash pickup success data
  final pickupCode = ''.obs;

  // Expiry countdown
  final expirySeconds = 0.obs; // remaining seconds
  DateTime? _expiresAt;
  Timer? _expiryTimer;

  // =============================
  // DEPENDENCIES
  // =============================
  final WalletController walletController = Get.find<WalletController>();
  final HomeController homeController = Get.find<HomeController>();
  final Dio _dio = DioClient().getInstance();

  // =============================
  // CONFIG
  // =============================
  static const String receiptBaseUrl = "https://cashpilot.app/cash-pickup";
  static const Duration fallbackExpiry = Duration(minutes: 15);

  @override
  void onInit() {
    super.onInit();

    receiverNameController.addListener(() {
      receiverName.value = receiverNameController.text.trim();
    });

    receiverPhoneController.addListener(() {
      receiverPhone.value = receiverPhoneController.text.trim();
    });
  }

  // =============================
  // COMPUTED
  // =============================
  double get availableBalance {
    switch (selectedCurrency.value) {
      case 'USD':
        return walletController.usdBalance.value;
      case 'EUR':
        return walletController.eurBalance.value;
      case 'LBP':
        return walletController.lbpBalance.value;
      default:
        return 0.0;
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

  double calculateFee() => fee.value;

  bool get canSend {
    return receiverName.value.isNotEmpty &&
        receiverPhone.value.isNotEmpty &&
        amount.value > 0 &&
        total.value <= availableBalance &&
        !isSending.value;
  }

  String get _verificationUrl {
    // Example: https://cashpilot.app/cash-pickup/ABC123
    final code = pickupCode.value;
    if (code.isEmpty) return receiptBaseUrl;
    return "$receiptBaseUrl/$code";
  }

  String get _expiryLabel {
    final secs = expirySeconds.value;
    if (secs <= 0) return "Expired";

    final minutes = secs ~/ 60;
    final seconds = secs % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return "$mm:$ss";
  }

  // =============================
  // ACTIONS
  // =============================
  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
    fetchFeePreview();
  }

  void updateAmount(String value) {
    amount.value = double.tryParse(value) ?? 0.0;
    fetchFeePreview();
  }

  // =============================
  // 🔐 FEE PREVIEW (BACKEND)
  // =============================
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
          "context": "cash_pickup",
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

  // =============================
  // API CALL
  // =============================
  Future<void> sendCashPickup() async {
    if (!canSend) return;

    isSending.value = true;

    try {
      final response = await _dio.post(
        "cash-pickup/send",
        data: {
          "receiver_full_name": receiverNameController.text.trim(),
          "receiver_phone": receiverPhoneController.text.trim(),
          "receiver_email": receiverEmailController.text.trim().isEmpty
              ? null
              : receiverEmailController.text.trim(),
          "amount": amount.value,
          "currency": selectedCurrency.value,
          "note": noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        },
      );

      final data = response.data ?? {};

      pickupCode.value = (data["pickup_code"] ?? "").toString();

      // Expiry handling (robust):
      // Accepts expires_at (ISO string) OR expires_in_seconds OR expires_in_minutes
      _setExpiryFromBackend(data);

      // Backend is source of truth
      await walletController.refreshAll();
      await homeController.fetchDashboardData();

      _showSuccessDialog();
    } catch (e) {
      Get.snackbar(
        "Error",
        e is DioException
            ? (e.response?.data["message"] ?? "Failed to send cash")
            : "Failed to send cash",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  void _setExpiryFromBackend(dynamic data) {
    _expiresAt = null;

    try {
      final expiresAtRaw = data["expires_at"];
      final expiresInSecondsRaw = data["expires_in_seconds"];
      final expiresInMinutesRaw = data["expires_in_minutes"];

      if (expiresAtRaw != null) {
        final parsed = DateTime.tryParse(expiresAtRaw.toString());
        if (parsed != null) _expiresAt = parsed.toLocal();
      } else if (expiresInSecondsRaw != null) {
        final secs = int.tryParse(expiresInSecondsRaw.toString());
        if (secs != null)
          _expiresAt = DateTime.now().add(Duration(seconds: secs));
      } else if (expiresInMinutesRaw != null) {
        final mins = int.tryParse(expiresInMinutesRaw.toString());
        if (mins != null)
          _expiresAt = DateTime.now().add(Duration(minutes: mins));
      }
    } catch (_) {}

    _expiresAt ??= DateTime.now().add(fallbackExpiry);

    _startExpiryCountdown();
  }

  void _startExpiryCountdown() {
    _expiryTimer?.cancel();

    void tick() {
      final now = DateTime.now();
      final diff = _expiresAt!.difference(now).inSeconds;
      expirySeconds.value = diff > 0 ? diff : 0;
    }

    tick();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  // =============================
  // SUCCESS UI (REDESIGNED)
  // =============================
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
                    "Cash Ready for Pickup",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "Share this code with the receiver",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Pickup Code Card
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
                          "Pickup Code",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => Text(
                            pickupCode.value.isEmpty ? "-" : pickupCode.value,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: Colors.white,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Expiry Timer
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: expirySeconds.value > 300
                            ? const Color(0xFFECFDF5)
                            : expirySeconds.value > 60
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: expirySeconds.value > 300
                              ? const Color(0xA010B981)
                              : expirySeconds.value > 60
                              ? const Color(0xA0F59E0B)
                              : const Color(0xA0EF4444),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 20,
                            color: expirySeconds.value > 300
                                ? const Color(0xFF10B981)
                                : expirySeconds.value > 60
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Expires in: $_expiryLabel",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: expirySeconds.value > 300
                                  ? const Color(0xFF10B981)
                                  : expirySeconds.value > 60
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Copy Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: pickupCode.value.isEmpty
                            ? null
                            : () async {
                                await Clipboard.setData(
                                  ClipboardData(text: pickupCode.value),
                                );
                                Get.snackbar(
                                  "",
                                  "Pickup code copied to clipboard",
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
                          "Copy Code",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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
                        _clear();
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

  // =============================
  // SHARE DIALOG (REDESIGNED)
  // =============================
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
                  await _shareViaEmail();
                } else if (type == "pdf") {
                  await _sharePdf();
                } else {
                  await _shareImage();
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

  // =============================
  // RECEIPT MESSAGE (TEXT)
  // =============================
  String _buildReceiptText() {
    final receiverEmail = receiverEmailController.text.trim();
    final receiverPhoneText = receiverPhoneController.text.trim();
    final note = noteController.text.trim();
    final formattedAmount = amount.value.toStringAsFixed(2);
    final formattedFee = fee.value.toStringAsFixed(2);
    final formattedTotal = total.value.toStringAsFixed(2);
    final receiverName = receiverNameController.text.trim();

    final noteSection = note.isNotEmpty ? '\n\nNote:\n$note' : '';

    return '''

                    CashPilot Cash Pickup Receipt
                   --------------------------------------------

PICKUP CODE:
---------------------
${pickupCode.value}


TRANSACTION DETAILS
---------------------------------
Amount:           $currencySymbol$formattedAmount
Service Fee:      $currencySymbol$formattedFee

Total Amount:     $currencySymbol$formattedTotal (${selectedCurrency.value})


RECEIVER INFORMATION
----------------------------------
Name:             $receiverName
Phone:            ${receiverPhoneText.isEmpty ? 'Not provided' : receiverPhoneText}
Email:            ${receiverEmail.isEmpty ? 'Not provided' : receiverEmail}


VALIDITY & VERIFICATION
-----------------------------------
Code Expires:     $_expiryLabel
Verification:     $_verificationUrl$noteSection



Thank you for using CashPilot!
Visit: www.cashpilot.app

''';
  }

  // =============================
  // EMAIL SHARE (AUTO-FILL RECEIVER EMAIL)
  // =============================
  Future<void> _shareViaEmail() async {
    if (pickupCode.value.isEmpty) return;

    final receiverEmail = receiverEmailController.text.trim();
    if (receiverEmail.isEmpty) {
      Get.snackbar(
        "Missing Email",
        "Receiver email is empty",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: receiverEmail, // ✅ auto-filled receiver email
      queryParameters: {
        'subject': 'CashPilot Cash Pickup Receipt',
        'body': _buildReceiptText(),
      },
    );

    if (!await canLaunchUrl(uri)) {
      _error("Cannot open email app");
      return;
    }

    await _logShare("email");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // =============================
  // PDF SHARE
  // =============================
  Future<File> _generatePdfReceipt() async {
    final pdf = pw.Document();
    final text = _buildReceiptText();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "CashPilot – Cash Pickup Receipt",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(text),
            ],
          ),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/CashPickup_${pickupCode.value}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _sharePdf() async {
    if (pickupCode.value.isEmpty) return;

    try {
      final file = await _generatePdfReceipt();
      await _logShare("pdf");

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "CashPilot Cash Pickup Receipt");
    } catch (_) {
      _error("Failed to share PDF receipt");
    }
  }

  // =============================
  // IMAGE SHARE (PNG)
  // =============================
  Future<File> _generateImageReceipt() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const width = 1080.0;
    const height = 820.0;

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
      y += textPainter.height + 14;
    }

    draw("CashPilot – Cash Pickup Receipt", 30, FontWeight.bold);
    draw("Pickup Code: ${pickupCode.value}", 22, FontWeight.bold);
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
    draw(
      "Receiver: ${receiverNameController.text.trim()}",
      18,
      FontWeight.normal,
    );
    draw("Expires In: $_expiryLabel", 18, FontWeight.normal);
    draw("Verify: $_verificationUrl", 16, FontWeight.normal);

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/CashPickup_${pickupCode.value}.png");
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    return file;
  }

  Future<void> _shareImage() async {
    if (pickupCode.value.isEmpty) return;

    try {
      final file = await _generateImageReceipt();
      await _logShare("image");

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "CashPilot Cash Pickup Receipt");
    } catch (_) {
      _error("Failed to share image receipt");
    }
  }

  // =============================
  // BACKEND SHARE LOG
  // =============================
  Future<void> _logShare(String method) async {
    try {
      await _dio.post(
        "transactions/share",
        data: {
          // For cash pickup we don’t have transaction_id in your response,
          // so we log pickup code as recipient reference.
          "transaction_id": 0,
          "method": method,
          "recipient": receiverEmailController.text.trim().isEmpty
              ? receiverPhoneController.text.trim()
              : receiverEmailController.text.trim(),
          "meta": {
            "pickup_code": pickupCode.value,
            "currency": selectedCurrency.value,
            "amount": amount.value,
            "fee": fee.value,
            "total": total.value,
          },
        },
      );
    } catch (_) {
      // Do nothing — sharing must still work even if logging fails
    }
  }

  // =============================
  // HELPERS
  // =============================
  void _error(String msg) {
    Get.snackbar(
      "Error",
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _clear() {
    receiverNameController.clear();
    receiverPhoneController.clear();
    receiverEmailController.clear();
    amountController.clear();
    noteController.clear();

    amount.value = 0.0;
    fee.value = 0.0;
    total.value = 0.0;

    pickupCode.value = '';
    expirySeconds.value = 0;
    _expiresAt = null;

    _expiryTimer?.cancel();
    _expiryTimer = null;
  }

  @override
  void onClose() {
    _expiryTimer?.cancel();
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    receiverEmailController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
