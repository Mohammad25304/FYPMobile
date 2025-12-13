import 'package:cashpilot/Core/Network/ServicesAPI.dart';
import 'package:get/get.dart';
import '../Model/Service.dart';
import 'HomeController.dart';

class ServiceController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final ServicesApi _api = ServicesApi();

  var services = <ServiceModel>[].obs;
  var expandedServiceId = Rx<String?>(null);
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  bool get isAccountActive => homeController.accountStatus.value == 'active';

  void toggleService(String serviceId) {
    expandedServiceId.value = expandedServiceId.value == serviceId
        ? null
        : serviceId;
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;

      final data = await _api.fetchServices();
      services.value = data.map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services');
    } finally {
      isLoading.value = false;
    }
  }
}
