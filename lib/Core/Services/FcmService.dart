import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../Network/DioClient.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ✅ ADD THIS METHOD (FIXES YOUR ERROR)
  static Future<String?> getToken() async {
    await _messaging.requestPermission();
    return await _messaging.getToken();
  }

  // ✅ Use this AFTER login
  static Future<void> sendTokenToBackend() async {
    final token = await getToken();
    if (token == null) return;

    final dio = DioClient().getInstance();
    await dio.post('save-fcm-token', data: {'fcm_token': token});
  }
}
