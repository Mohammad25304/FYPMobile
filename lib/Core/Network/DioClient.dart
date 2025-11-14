import 'package:dio/dio.dart';

class DioClient {
  Dio getInstance() {
    return Dio(
      BaseOptions(
        baseUrl: "http://localhost:8000/api/",
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'applicaton/json',
        },
      ),
    );
  }
}
