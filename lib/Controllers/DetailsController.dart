import 'package:get/get.dart';
import 'package:cashpilot/Model/Detail.dart';

class DetailsController extends GetxController {
  // List of detail items
  RxList<Detail> detailsList = <Detail>[
    Detail(
      title: 'Profile',
      keyName: 'profile',
      description: 'Here you can edit your profile',
    ),
    Detail(
      title: 'Notification',
      keyName: 'notification',
      description: 'Here you can see your notifications',
    ),
    Detail(
      title: "About Us",
      keyName: "about_us",
      description: "Learn more about our mission and values.",
    ),
    Detail(
      title: "Help Center",
      keyName: "help_center",
      description: "Frequently asked questions and support.",
    ),
    Detail(
      title: "Privacy Policy",
      keyName: "privacy",
      description: "How we manage and protect your data.",
    ),
    Detail(
      title: "Terms & Conditions",
      keyName: "terms",
      description: "Please read our user agreement.",
    ),
    Detail(
      title: "Contact Info",
      keyName: "contact",
      description: "Phone number, email & office address.",
    ),
    Detail(
      title: "Settings",
      keyName: "settings",
      description: "Manage application preferences.",
    ),
  ].obs;

  // Later this will call API
  Future<void> fetchDetailsFromApi() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: GET /details from Laravel
  }
}
