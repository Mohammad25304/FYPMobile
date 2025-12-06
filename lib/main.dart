import 'package:cashpilot/Routes/AppRoute.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Routes/AppPage.dart';

void main() {
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
