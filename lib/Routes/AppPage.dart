import 'package:cashpilot/Routes/AppRoute.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Bindings/RegistrationBinding.dart';
import 'package:cashpilot/Views/Registration.dart';

class AppPage {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoute.Register,
      page: () => const Registration(),
      binding: RegistrationBinding(),
    ),
  ];
}
