import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart'; // vibration/haptics
import 'package:cashpilot/Controllers/AddMoneyController.dart';

class QrScan extends StatefulWidget {
  const QrScan({super.key});

  @override
  State<QrScan> createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> with SingleTickerProviderStateMixin {
  final controller = Get.find<AddMoneyController>();
  final scanner = MobileScannerController();

  late AnimationController _animationController;
  late Animation<double> _animation;

  bool scanned = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    scanner.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (scanned) return;

    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;

    if (value != null) {
      scanned = true;

      // Native vibration (no plugin)
      HapticFeedback.mediumImpact();

      controller.handleQrScan(value);

      await scanner.stop();
      await Future.delayed(const Duration(milliseconds: 300));

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: scanner,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),

          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          Center(
            child: CustomPaint(
              size: Size(size.width * 0.8, size.width * 0.8),
              painter: _ScannerOverlayPainter(),
            ),
          ),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: size.height * 0.2 + (size.width * 0.8 * _animation.value),
                left: size.width * 0.1,
                child: Container(
                  width: size.width * 0.8,
                  height: 3,
                  color: Colors.blueAccent.withOpacity(0.9),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final cornerPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, borderPaint);

    const c = 40.0;

    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + const Offset(c, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + const Offset(0, c),
      cornerPaint,
    );

    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(-c, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(0, c),
      cornerPaint,
    );

    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(c, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(0, -c),
      cornerPaint,
    );

    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-c, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -c),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
