import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../Model/ChatMessage.dart';
import '../Core/Network/DioClient.dart';

class ChatbotController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  var messages = <ChatMessage>[].obs;
  var isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['mode'] == 'faq') {
      sendMessage('Show me frequently asked questions about CashPilot');
    }
    // Welcome message
    messages.add(
      ChatMessage(
        message:
            "Hi 👋 I’m the CashPilot Assistant. I can help you understand how the app works.",
        isUser: false,
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(ChatMessage(message: text, isUser: true));
    isTyping.value = true;

    try {
      final response = await _dio.post(
        'chatbot/message',
        data: {'message': text},
      );

      messages.add(ChatMessage(message: response.data['reply'], isUser: false));
    } catch (e) {
      messages.add(
        ChatMessage(
          message:
              "Sorry, I couldn't process your request right now. Please try again.",
          isUser: false,
        ),
      );
    } finally {
      isTyping.value = false;
    }
  }
}
