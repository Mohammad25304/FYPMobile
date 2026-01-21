import 'package:cashpilot/Core/Services/LocalNotificationService.dart';
import 'package:cashpilot/Routes/AppRoute.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Routes/AppPage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔴 REQUIRED in background isolate
  await LocalNotificationService.init();

  final data = message.data;

  if (data.isNotEmpty) {
    await LocalNotificationService.show(
      title: data['title'] ?? 'CashPilot',
      body: data['body'] ?? '',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔴 REQUIRED FOR ANDROID 13+
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await LocalNotificationService.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((message) {
    final data = message.data;

    if (data.isNotEmpty) {
      LocalNotificationService.show(
        title: data['title'] ?? 'CashPilot',
        body: data['body'] ?? '',
      );
    }
  });

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null && message.data.isNotEmpty) {
      LocalNotificationService.show(
        title: message.data['title'] ?? 'CashPilot',
        body: message.data['body'] ?? '',
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CashPilot',
      theme: ThemeData(primarySwatch: Colors.lightBlue, useMaterial3: true),
      initialRoute: AppRoute.register,
      getPages: AppPage.pages,
    );
  }
}
