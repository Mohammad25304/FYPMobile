import 'package:dio/dio.dart';
import 'DioClient.dart';

class TransferService {
  static Future<Map<String, dynamic>> transfer({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    String? note,
  }) async {
    final dio = DioClient().getInstance();

    final response = await dio.post(
      'transfer',
      data: {
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
        'amount': amount,
        'note': note,
      },
    );

    return response.data;
  }
}
