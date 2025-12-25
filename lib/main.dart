import 'package:cashpilot/Routes/AppRoute.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Routes/AppPage.dart';
import 'package:cashpilot/Core/Services/FcmService.dart';

// 🔥 ADD THESE TWO IMPORTS
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // 🔥 REQUIRED for Firebase

  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase
  await Firebase.initializeApp();

  FcmService.getToken().then((token) {
    print('🔥 FCM TOKEN: $token');
  });

  // ✅ YOUR CODE (UNCHANGED)
  runApp(const MyApp());
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
