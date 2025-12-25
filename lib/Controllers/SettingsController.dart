import 'package:get/get.dart';

class SettingsController extends GetxController {
  var notificationsEnabled = true.obs;
  var darkModeEnabled = false.obs;
  var selectedCurrency = 'USD'.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    // TODO: Save to backend or local storage
  }

  void toggleDarkMode(bool value) {
    darkModeEnabled.value = value;
    // TODO: Apply theme & persist
  }

  void changeCurrency(String value) {
    selectedCurrency.value = value;
    // TODO: Save preference
  }

  void logout() {
    // TODO: Clear session & redirect to login
  }
}
