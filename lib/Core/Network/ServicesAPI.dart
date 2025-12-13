import 'package:dio/dio.dart';
import '../Network/DioClient.dart';

class ServicesApi {
  final Dio _dio = DioClient().getInstance();

  Future<List<dynamic>> fetchServices() async {
    final response = await _dio.get('services');
    return response.data;
  }
}
