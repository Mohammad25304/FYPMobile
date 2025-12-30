import 'package:firebase_messaging/firebase_messaging.dart';
import '../Network/DioClient.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // 🔥 Call once at app start
  static Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // 🔥 Call AFTER login
  static Future<void> sendTokenToBackend() async {
    final token = await getToken();
    if (token == null) return;

    final dio = DioClient().getInstance();
    await dio.post('save-fcm-token', data: {'fcm_token': token});
  }
}
