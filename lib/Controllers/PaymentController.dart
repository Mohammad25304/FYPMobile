import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class PaymentController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  RxBool isLoading = false.obs;
  RxList<dynamic> payments = <dynamic>[].obs;

  Future<void> fetchPayments() async {
    try {
      isLoading.value = true;

      final response = await _dio.get("payments");

      payments.assignAll(response.data["payments"]);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load payments",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
