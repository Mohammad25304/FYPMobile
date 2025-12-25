import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class PrivacyController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  var isLoading = true.obs;
  var title = 'Privacy Policy'.obs;
  var content = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrivacy();
  }

  Future<void> fetchPrivacy() async {
    try {
      final response = await _dio.get('details/privacy');
      content.value = response.data['content'];
    } finally {
      isLoading.value = false;
    }
  }
}
