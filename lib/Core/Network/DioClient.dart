import 'package:dio/dio.dart';

class DioClient {
  Dio getInstance({bool useJson = true}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.1.68:8000/api/",
        connectTimeout: const Duration(seconds: 30), // Increased timeout
        receiveTimeout: const Duration(seconds: 30),
        headers: useJson
            ? {"Accept": "application/json", "Content-Type": "application/json"}
            : {
                "Accept": "application/json",
                "Content-Type": "multipart/form-data",
              },
      ),
    );

    // Add interceptor for better error logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌐 REQUEST[${options.method}] => ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
            '❌ ERROR[${e.response?.statusCode}] => ${e.requestOptions.uri}',
          );
          print('Error Type: ${e.type}');
          print('Error Message: ${e.message}');
          print('Error Response: ${e.response}');

          // Provide user-friendly error messages
          String errorMessage;
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
              errorMessage =
                  'Connection timeout - Please check your internet connection';
              break;
            case DioExceptionType.connectionError:
              errorMessage =
                  'Cannot connect to server - Make sure you\'re on the same WiFi network';
              break;
            case DioExceptionType.badResponse:
              errorMessage = 'Server error: ${e.response?.statusCode}';
              break;
            default:
              errorMessage = 'Network error: ${e.message}';
          }

          print('User Message: $errorMessage');
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}
