import 'package:cashpilot/Bindings/AddMoneyBinding.dart';
import 'package:cashpilot/Bindings/CashPickupBinding.dart';
import 'package:cashpilot/Bindings/ContactInfoBinding.dart';
import 'package:cashpilot/Bindings/DetailBinding.dart';
import 'package:cashpilot/Bindings/ForgetPasswordEmailBinding.dart';
import 'package:cashpilot/Bindings/ForgetPasswordOTPBinding.dart';
import 'package:cashpilot/Bindings/LoginBinding.dart';
import 'package:cashpilot/Bindings/MonthlyStatsBinding.dart';
import 'package:cashpilot/Bindings/NotificationBinding.dart';
import 'package:cashpilot/Bindings/OtpVerificationBinding.dart';
import 'package:cashpilot/Bindings/PaymentBinding.dart';
import 'package:cashpilot/Bindings/ProfileBinding.dart';
import 'package:cashpilot/Bindings/SendMoneyBinding.dart';
import 'package:cashpilot/Bindings/ServiceBinding.dart';
import 'package:cashpilot/Routes/AppRoute.dart';
import 'package:cashpilot/Views/AddMoney.dart';
import 'package:cashpilot/Views/ContactInfo.dart';
import 'package:cashpilot/Views/ForgetPassword.dart';
import 'package:cashpilot/Views/ForgetPasswordOtp.dart';
import 'package:cashpilot/Views/MonthlyStatsPage.dart';
import 'package:cashpilot/Views/NotificationsView.dart';
import 'package:cashpilot/Views/OtpVerificationPage.dart';
import 'package:cashpilot/Views/Payment.dart';
import 'package:cashpilot/Views/Profile.dart';
import 'package:cashpilot/Views/QrScan.dart';
import 'package:cashpilot/Views/ResetPassword.dart';
import 'package:cashpilot/Views/SendCashPickup.dart';
import 'package:cashpilot/Views/SendMoney.dart';
import 'package:cashpilot/Views/Service.dart';
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
import 'package:cashpilot/Views/Details.dart';

class AppPage {
  static final List<GetPage> pages = [
    //Get page for registration
    GetPage(
      name: AppRoute.register,
      page: () => const Registration(),
      binding: RegistrationBinding(),
    ),

    //Get page for otp verification
    GetPage(
      name: AppRoute.otp,
      page: () => OtpVerificationPage(),
      binding: OtpVerificationBinding(),
    ),

    //Get page for login
    GetPage(name: AppRoute.login, page: () => Login(), binding: LoginBinding()),

    //Get page for home
    GetPage(name: AppRoute.home, page: () => Home(), binding: HomeBinding()),

    //Get page for wallet
    GetPage(
      name: '/wallet',
      page: () => const Wallet(),
      binding: WalletBinding(),
    ),

    //Get page for send money
    GetPage(
      name: '/sendMoney',
      page: () => SendMoney(),
      binding: SendMoneyBinding(),
    ),

    //Get page for transfer money
    GetPage(
      name: '/transferMoney',
      page: () => const TransferMoney(),
      binding: TransferMoneyBinding(),
    ),
    // Get page for add money
    GetPage(
      name: '/addMoney',
      page: () => AddMoney(),
      binding: AddMoneyBinding(),
    ),

    GetPage(name: '/qrScan', page: () => QrScan(), binding: AddMoneyBinding()),

    //Get page for forget password
    GetPage(
      name: '/forgetPassword',
      page: () => const ForgetPassword(),
      binding: ForgetPasswordEmailBinding(),
    ),

    //Get page for forget password otp
    GetPage(
      name: '/forgetPasswordOtp',
      page: () => const ForgetPasswordOTP(),
      binding: ForgetPasswordOTPBinding(),
    ),

    //Get page for reset password
    GetPage(
      name: '/resetPassword',
      page: () => const ResetPassword(),
      binding: ForgetPasswordOTPBinding(),
    ),

    //Get page for payment
    GetPage(name: '/payment', page: () => Payment(), binding: PaymentBinding()),

    GetPage(
      name: '/detail',
      page: () => const Details(),
      binding: DetailsBinding(),
    ),

    GetPage(
      name: '/profile',
      page: () => const Profile(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoute.service,
      page: () => const Service(),
      binding: ServiceBinding(),
    ),

    GetPage(
      name: AppRoute.sendCashPickup,
      page: () => const SendCashPickup(),
      binding: CashPickupBinding(),
    ),

    GetPage(
      name: '/contactInfo',
      page: () => const ContactInfoPage(),
      binding: ContactInfoBinding(),
    ),

    GetPage(
      name: '/monthlyStats',
      page: () => const MonthlyStatsPage(),
      binding: MonthlyStatsBinding(),
    ),

    GetPage(
      name: AppRoute.notification,
      page: () => const NotificationsView(),
      binding: NotificationBinding(),
    ),
  ];
}
