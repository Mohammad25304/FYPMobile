import 'package:cashpilot/Core/Services/LocalNotificationService.dart';
import 'package:cashpilot/Routes/AppRoute.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Routes/AppPage.dart';
import 'package:cashpilot/Core/Services/FcmService.dart';

// 🔥 Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // 🔔 Init local notifications
  await LocalNotificationService.init();

  // 🔥 Background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔥 Foreground notifications
  FirebaseMessaging.onMessage.listen((message) {
    final notification = message.notification;
    if (notification != null) {
      LocalNotificationService.show(
        title: notification.title ?? 'CashPilot',
        body: notification.body ?? '',
      );
    }
  });

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CashPilot',
      theme: ThemeData(primarySwatch: Colors.lightBlue, useMaterial3: true),
      initialRoute: AppRoute.register,
      getPages: AppPage.pages,
    );
  }
}
