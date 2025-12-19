import 'package:get/get.dart';
import 'package:cashpilot/Model/ContactInfo.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:dio/dio.dart' as dio;

class ContactInfoController extends GetxController {
  final dio.Dio _dio = DioClient().getInstance();

  var isLoading = true.obs;
  var hasError = false.obs;

  late ContactInfo contactInfo;

  @override
  void onInit() {
    super.onInit();
    fetchContactInfo();
  }

  Future<void> fetchContactInfo() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final dio.Response response = await _dio.get('app/contact-info');

      contactInfo = ContactInfo.fromJson(response.data['data']);
    } catch (e) {
      hasError.value = true;
      print('❌ Failed to load contact info: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
