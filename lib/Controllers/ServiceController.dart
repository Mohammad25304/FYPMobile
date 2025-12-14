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
    print('✅ ServiceController INIT');
    print('Account status: ${homeController.accountStatus.value}');
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

      services.assignAll(
        data.map<ServiceModel>((e) => ServiceModel.fromJson(e)).toList(),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load services',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
