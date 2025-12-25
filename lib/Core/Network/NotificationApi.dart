import 'package:dio/dio.dart';
import 'DioClient.dart';

class NotificationApi {
  final Dio _dio = DioClient().getInstance();

  Future<Response> getNotifications() {
    return _dio.get('notifications');
  }

  Future<Response> markAsRead(String id) {
    return _dio.post('notifications/$id/read');
  }

  Future<Response> clearAll() {
    return _dio.delete('notifications/clear');
  }

  Future<Response> deleteOne(String id) {
    return _dio.delete('notifications/$id');
  }
}
