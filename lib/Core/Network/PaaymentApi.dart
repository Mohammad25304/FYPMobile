import 'package:dio/dio.dart';
import 'DioClient.dart';

class PaymentApi {
  final Dio _dio = DioClient().getInstance();
  //telecom payment
  Future<void> payTelecom({
    required String provider,
    required String phone,
    required double amount,
    required String currency,
  }) async {
    await _dio.post(
      'pay/telecom',
      data: {
        'provider': provider,
        'phone': phone,
        'amount': amount,
        'currency': currency,
      },
    );
  }

  //internet payment
  Future<void> payInternet({
    required String provider,
    required String accountNumber,
    required double amount,
    required String currency,
  }) async {
    await _dio.post(
      'pay/internet',
      data: {
        'provider': provider,
        'account_number': accountNumber,
        'amount': amount,
        'currency': currency,
      },
    );
  }
}
