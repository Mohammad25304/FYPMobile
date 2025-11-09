// import 'package:dio/dio.dart';

// class DioClient{
//   Dio getInstance(){
//     Dio dio = Dio();
//     dio.options.baseUrl = "https://example.com/api";
//     dio.options.connectTimeout = 5000;
//     dio.options.receiveTimeout = 3000;


//     dio.interceptors.add(InterceptorsWrapper{
//       onRequest: (options, handler){
//         return handler.next(options);
//     }
//     });

//   }
// }