import 'package:cashpilot/Bindings/LoginBinding.dart';
import 'package:cashpilot/Bindings/OtpVerificationBinding.dart';
import 'package:cashpilot/Routes/AppRoute.dart';
import 'package:cashpilot/Views/OtpVerificationPage.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Bindings/RegistrationBinding.dart';
import 'package:cashpilot/Views/Registration.dart';
import 'package:cashpilot/Views/Login.dart';

class AppPage {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoute.register,
      page: () => const Registration(),
      binding: RegistrationBinding(),
    ),

    GetPage(
      name: AppRoute.otp,
      page: () => OtpVerificationPage(),
      binding: OtpVerificationBinding(),
    ),

    GetPage(name: AppRoute.login, page: () => Login(), binding: LoginBinding()),
  ];
}
