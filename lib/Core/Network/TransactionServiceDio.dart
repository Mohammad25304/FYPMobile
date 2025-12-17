import 'DioClient.dart';

class TransactionService {
  /// Fetches transactions from the API and always returns a map with a
  /// `transactions` list to match WalletController expectations.
  static Future<Map<String, dynamic>> fetchTransactions() async {
    final dio = DioClient().getInstance();
    final response = await dio.get('transactions');

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is List) {
      // Backend returned a raw list; wrap it so the controller can consume it.
      return {'transactions': data};
    }

    // Fallback to an empty list to avoid runtime errors.
    return {'transactions': <dynamic>[]};
  }
}
