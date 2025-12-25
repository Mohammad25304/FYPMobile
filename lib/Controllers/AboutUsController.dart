// Controllers/AboutUsController.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class AboutUsController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  var isLoading = true.obs;
  var title = ''.obs;
  var content = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAboutUs();
  }

  Future<void> fetchAboutUs() async {
    try {
      final response = await _dio.get('details/about_us');
      title.value = response.data['title'];
      content.value = response.data['content'];
    } finally {
      isLoading.value = false;
    }
  }
}
