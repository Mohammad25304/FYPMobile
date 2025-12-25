import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class TermsController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  var isLoading = true.obs;
  var content = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    try {
      final response = await _dio.get('details/terms');
      content.value = response.data['content'];
    } finally {
      isLoading.value = false;
    }
  }
}
