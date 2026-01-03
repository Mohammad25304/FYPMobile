import 'package:dio/dio.dart';
import 'DioClient.dart';

class PaymentApi {
  final Dio _dio = DioClient().getInstance();

  // =============================
  // TELECOM RECHARGE
  // =============================
  Future<Map<String, dynamic>> payTelecom({
    required String provider,
    required int provider_id,
    required String phone,
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await _dio.post(
        'payments/telecom',
        data: {
          'provider': provider,
          'provider_id': provider_id,
          'phone': phone,
          'amount': amount,
          'currency': currency,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  // INTERNET BILL PAYMENT
  // =============================
  Future<Map<String, dynamic>> payInternet({
    required String provider,
    required String accountNumber,
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await _dio.post(
        'payments/internet',
        data: {
          'provider': provider,
          'account_number': accountNumber,
          'amount': amount,
          'currency': currency,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  // GOVERNMENT SERVICE PAYMENT
  // =============================
  Future<Map<String, dynamic>> payGovernment({
    required String provider,
    required int serviceId,
    required String referenceNumber,
    required double amount,
    required String currency,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        'payments/government',
        data: {
          'provider': provider,
          'service_id': serviceId,
          'reference_number': referenceNumber,
          'amount': amount,
          'currency': currency,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  // EDUCATION FEE PAYMENT
  // =============================
  Future<Map<String, dynamic>> payEducation({
    required String provider,
    required int serviceId,
    required String studentId,
    required String studentName,
    required String semester,
    required String paymentType,
    required double amount,
    required String currency,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        'payments/education',
        data: {
          'provider': provider,
          'service_id': serviceId,
          'student_id': studentId,
          'student_name': studentName,
          'semester': semester,
          'payment_type': paymentType,
          'amount': amount,
          'currency': currency,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  // FEE PREVIEW (UNIVERSAL)
  // =============================
  Future<Map<String, dynamic>> getFeePreview({
    required String context,
    required int serviceId,
    required String currency,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        'fees/preview',
        data: {
          'context': context,
          'service_id': serviceId,
          'currency': currency,
          'amount': amount,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  // GET PAYMENT HISTORY
  // =============================
  Future<List<dynamic>> getPaymentHistory({
    String? type, // 'telecom', 'internet', 'government'
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get(
        'payments/history',
        queryParameters: {
          if (type != null) 'type': type,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      return response.data['payments'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  // GET PAYMENT DETAILS BY ID
  // =============================
  Future<Map<String, dynamic>> getPaymentDetails(int paymentId) async {
    try {
      final response = await _dio.get('payments/$paymentId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  // GET SERVICE PROVIDERS
  // =============================
  Future<List<dynamic>> getProviders({
    required String type, // 'telecom', 'internet', 'government'
  }) async {
    try {
      final response = await _dio.get(
        'providers',
        queryParameters: {'type': type},
      );

      return response.data['providers'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  // VERIFY ACCOUNT/REFERENCE
  // =============================
  Future<Map<String, dynamic>> verifyAccount({
    required String type, // 'internet', 'government'
    required int serviceId,
    required String accountNumber,
  }) async {
    try {
      final response = await _dio.post(
        'payments/verify',
        data: {
          'type': type,
          'service_id': serviceId,
          'account_number': accountNumber,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  // CANCEL/REFUND PAYMENT
  // =============================
  Future<Map<String, dynamic>> cancelPayment({
    required int paymentId,
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        'payments/$paymentId/cancel',
        data: {'reason': reason},
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
