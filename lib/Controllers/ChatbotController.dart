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

    messages.add(
      ChatMessage(
        message:
            "Hi 👋 I’m the CashPilot Assistant. You can tap a question below or ask your own.",
        isUser: false,
      ),
    );

    if (args != null && args['mode'] == 'faq') {
      loadFaqs();
    }
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

  Future<void> loadFaqs() async {
    isTyping.value = true;

    try {
      final response = await _dio.get('chatbot/faqs');

      for (var faq in response.data['faqs']) {
        messages.add(ChatMessage(message: "❓ ${faq['intent']}", isUser: false));
      }
    } catch (e) {
      messages.add(
        ChatMessage(message: "Unable to load FAQs right now.", isUser: false),
      );
    } finally {
      isTyping.value = false;
    }
  }
}
