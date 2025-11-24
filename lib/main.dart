import 'package:cashpilot/Routes/AppRoute.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Routes/AppPage.dart';

// ADD imports for controllers:
import 'package:cashpilot/Controllers/HomeController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Controllers/SendMoneyController.dart';

void main() {
  // 🔥 REGISTER CONTROLLERS HERE (GLOBAL)
  Get.put(HomeController());
  Get.put(WalletController());
  Get.put(SendMoneyController());

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
