import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class ChatbotController extends GetxController {
  late final WebViewController webViewController;

  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initWebView();
  }

  void _initWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            isLoading.value = true;
            hasError.value = false;
          },
          onPageFinished: (_) {
            isLoading.value = false;
          },
          onWebResourceError: (_) {
            hasError.value = true;
            isLoading.value = false;
          },
        ),
      )
      ..loadHtmlString(_chatlingHtml, baseUrl: 'https://chatling.ai');
  }

  static const String _chatlingHtml = """
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>

<script>
  window.chtlConfig = {
    chatbotId: "6412128358",
    display: "fullscreen"
  };
</script>

<script async
        data-id="6412128358"
        data-display="fullscreen"
        id="chtl-script"
        type="text/javascript"
        src="https://chatling.ai/js/embed.js">
</script>

</body>
</html>
""";

  Future<bool> onWillPop() async {
    if (await webViewController.canGoBack()) {
      await webViewController.goBack();
      return false;
    }
    return true;
  }
}
