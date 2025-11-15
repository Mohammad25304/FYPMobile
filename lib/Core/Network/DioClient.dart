import 'package:dio/dio.dart';

class DioClient {
  Dio getInstance({bool useJson = true}) {
    return Dio(
      BaseOptions(
        baseUrl: "http://192.168.1.71:8000/api/",
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: useJson
            ? {"Accept": "application/json"}
            : {
                "Accept": "application/json",
                "Content-Type": "multipart/form-data",
              },
      ),
    );
  }
}
