import 'package:cashpilot/Bindings/AddMoneyBinding.dart';
import 'package:cashpilot/Bindings/LoginBinding.dart';
import 'package:cashpilot/Bindings/OtpVerificationBinding.dart';
import 'package:cashpilot/Bindings/SendMoneyBinding.dart';
import 'package:cashpilot/Routes/AppRoute.dart';
import 'package:cashpilot/Views/AddMoney.dart';
import 'package:cashpilot/Views/OtpVerificationPage.dart';
import 'package:cashpilot/Views/QrScan.dart';
import 'package:cashpilot/Views/SendMoney.dart';
import 'package:cashpilot/Views/TransferMoney.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Bindings/RegistrationBinding.dart';
import 'package:cashpilot/Views/Registration.dart';
import 'package:cashpilot/Views/Login.dart';
import 'package:cashpilot/Views/Home.dart';
import 'package:cashpilot/Bindings/HomeBinding.dart';
import 'package:cashpilot/Bindings/WalletBinding.dart';
import 'package:cashpilot/Views/Wallet.dart';
import 'package:cashpilot/Bindings/TransferMoneyBinding.dart';

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

    GetPage(name: AppRoute.home, page: () => Home(), binding: HomeBinding()),

    GetPage(
      name: '/wallet',
      page: () => const Wallet(),
      binding: WalletBinding(),
    ),

    GetPage(
      name: '/sendMoney',
      page: () => const SendMoney(),
      binding: SendMoneyBinding(),
    ),

    GetPage(
      name: '/transferMoney',
      page: () => const TransferMoney(),
      binding: TransferMoneyBinding(),
    ),

    GetPage(
      name: '/addMoney',
      page: () => AddMoney(),
      binding: AddMoneyBinding(),
    ),

    GetPage(name: '/qrScan', page: () => QrScan(), binding: AddMoneyBinding()),
  ];
}
