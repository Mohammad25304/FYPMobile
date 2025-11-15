import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = DioClient().getInstance();

  // 📌 Register user
  Future<Response> registerUser(FormData formData) async {
    return await _dio.post("/register", data: formData);
  }

  // 📌 Verify OTP
  Future<Response> verifyOtp(String email, String otp) async {
    return await _dio.post("/verify-otp", data: {"email": email, "otp": otp});
  }

  // 📌 Resend OTP
  Future<Response> resendOtp(String email) async {
    return await _dio.post("/resend-otp", data: {"email": email});
  }
}
