import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Storage/SessionManager.dart'; // Import your SessionManager

class DioClient {
  Dio getInstance({bool useJson = true}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.193.27:8000/api/",
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: useJson
            ? {"Accept": "application/json", "Content-Type": "application/json"}
            : {
                "Accept": "application/json",
                "Content-Type": "multipart/form-data",
              },
      ),
    );

    // Add interceptor for authentication and error logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from SessionManager and add to headers
          final token = await SessionManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔐 TOKEN ADDED to request');
          } else {
            print('⚠️ NO TOKEN FOUND - User may not be logged in');
          }

          print('🌐 REQUEST[${options.method}] => ${options.uri}');
          print('Headers: ${options.headers}');
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
          print('Error Response: ${e.response?.data}');

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
              if (e.response?.statusCode == 401) {
                errorMessage = 'Unauthorized - Please login again';
                // Optional: Clear session and redirect to login
                // SessionManager.clearSession();
              } else {
                errorMessage = 'Server error: ${e.response?.statusCode}';
              }
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
