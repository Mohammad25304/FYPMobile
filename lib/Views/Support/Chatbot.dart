import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../Controllers/ChatbotController.dart';

class ChatbotPage extends GetView<ChatbotController> {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CashPilot Assistant'),
          backgroundColor: const Color(0xFF1E88E5),
        ),
        body: Obx(() {
          if (controller.hasError.value) {
            return _errorView();
          }

          return Stack(
            children: [
              WebViewWidget(controller: controller.webViewController),
              if (controller.isLoading.value)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        }),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Unable to load chatbot.\nPlease check your internet connection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
