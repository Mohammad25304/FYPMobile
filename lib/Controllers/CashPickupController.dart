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
  // SUCCESS UI (WITH COUNTDOWN + SHARE)
  // =============================
  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Cash Ready for Pickup",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),

              Text("Pickup Code", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 6),

              Obx(
                () => Text(
                  pickupCode.value.isEmpty ? "-" : pickupCode.value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Countdown
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: expirySeconds.value > 0
                          ? Colors.orange
                          : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Expires in: $_expiryLabel",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: expirySeconds.value > 0
                            ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Actions row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickupCode.value.isEmpty
                          ? null
                          : () async {
                              await Clipboard.setData(
                                ClipboardData(text: pickupCode.value),
                              );
                              Get.snackbar(
                                "Copied",
                                "Pickup code copied",
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            },
                      icon: const Icon(Icons.copy),
                      label: const Text("Copy"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showShareDialog();
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Share"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  _clear();
                  Get.back();
                  Get.back();
                },
                child: const Text("Back to Wallet"),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // =============================
  // SHARE DIALOG
  // =============================
  void _showShareDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Share Pickup Receipt",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              _shareButton("email", Icons.email, "Email (auto receiver)"),
              const SizedBox(height: 12),
              _shareButton("pdf", Icons.picture_as_pdf, "PDF"),
              const SizedBox(height: 12),
              _shareButton("image", Icons.image, "Image"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shareButton(String type, IconData icon, String title) {
    return Obx(
      () => InkWell(
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
        child: Opacity(
          opacity: isSharing.value ? 0.6 : 1,
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
              if (isSharing.value)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
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

    return '''
CashPilot – Cash Pickup Receipt

Pickup Code: ${pickupCode.value}
Amount: $currencySymbol${amount.value.toStringAsFixed(2)}
Fee: $currencySymbol${fee.value.toStringAsFixed(2)}
Total: $currencySymbol${total.value.toStringAsFixed(2)}
Currency: ${selectedCurrency.value}

Receiver Name: ${receiverNameController.text.trim()}
Receiver Phone: ${receiverPhoneText.isEmpty ? "-" : receiverPhoneText}
Receiver Email: ${receiverEmail.isEmpty ? "-" : receiverEmail}

Expires In: $_expiryLabel
Verify: $_verificationUrl
${note.isEmpty ? "" : "\nNote: $note"}

Thank you for using CashPilot 💙
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
