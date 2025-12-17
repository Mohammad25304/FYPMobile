import 'package:get/get.dart';
import 'package:cashpilot/Model/ContactInfo.dart';

class ContactInfoController extends GetxController {
  var isLoading = false.obs;

  late ContactInfo contactInfo;

  @override
  void onInit() {
    super.onInit();
    fetchContactInfo();
  }

  void fetchContactInfo() async {
    isLoading.value = true;

    // 🔹 TEMP DATA (later from API)
    await Future.delayed(const Duration(milliseconds: 500));

    contactInfo = ContactInfo(
      phone: '+961 81 979 130',
      email: 'cashpilotinfo@gmail.com',
      address: 'Beirut, Lebanon',
      website: 'https://cashpilot.app',
    );

    isLoading.value = false;
  }
}
