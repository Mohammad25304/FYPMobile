import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class HelpCenterController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  var isLoading = true.obs;
  var content = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHelpCenter();
  }

  Future<void> fetchHelpCenter() async {
    try {
      final response = await _dio.get('details/help_center');
      content.value = response.data['content'];
    } finally {
      isLoading.value = false;
    }
  }
}
