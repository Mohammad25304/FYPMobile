import 'package:cashpilot/Controllers/DetailsController.dart';
import 'package:cashpilot/Controllers/PaymentController.dart';
import 'package:cashpilot/Controllers/ServiceController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Model/Service.dart';
import 'package:cashpilot/Views/Details.dart';
import 'package:cashpilot/Views/Home.dart';
import 'package:cashpilot/Views/Payment.dart';
import 'package:cashpilot/Views/Wallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Service extends GetView<ServiceController> {
  const Service({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ================= APP BAR =================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),

      // ================= BODY =================
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.services.isEmpty) {
          return const Center(
            child: Text(
              'No services available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final service = controller.services[index];

                  return Obx(() {
                    final bool expanded =
                        controller.expandedServiceId.value == service.id;

                    final bool locked =
                        service.requiresActiveAccount &&
                        !controller.isAccountActive;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == controller.services.length - 1
                            ? 0
                            : 12,
                      ),
                      child: _serviceTile(
                        service: service,
                        locked: locked,
                        expanded: expanded,
                      ),
                    );
                  });
                }, childCount: controller.services.length),
              ),
            ),
          ],
        );
      }),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.off(() => const Home());
              break;
            case 1:
              Get.off(() => Wallet());
              break;
            case 2:
              Get.off(() => Payment());
              break;
            case 3:
              break;
            case 4:
              Get.off(() => Details());
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: "Payments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            activeIcon: Icon(Icons.apps),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_outlined),
            activeIcon: Icon(Icons.menu),
            label: "Details",
          ),
        ],
      ),
    );
  }

  // ================= SERVICE TILE =================
  Widget _serviceTile({
    required ServiceModel service,
    required bool locked,
    required bool expanded,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: locked
                ? Colors.grey.withOpacity(0.1)
                : const Color(0xFF1E88E5).withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _serviceHeader(service, locked, expanded),
          if (expanded && !locked) _providerList(service),
        ],
      ),
    );
  }

  // ================= SERVICE HEADER =================
  Widget _serviceHeader(ServiceModel service, bool locked, bool expanded) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (locked) {
          Get.snackbar(
            "Account Not Active",
            "Please verify your account to access this service",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        controller.toggleService(service.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _serviceIcon(locked),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: locked ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locked
                        ? "Verification required"
                        : expanded
                        ? "Select provider"
                        : "Tap to expand",
                    style: TextStyle(
                      fontSize: 12,
                      color: locked ? Colors.orange : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              locked
                  ? Icons.lock
                  : expanded
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: locked ? Colors.orange : const Color(0xFF1E88E5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceIcon(bool locked) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: locked
              ? [Colors.grey, Colors.grey.shade400]
              : [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.apps, color: Colors.white, size: 28),
    );
  }

  // ================= PROVIDERS =================
  Widget _providerList(ServiceModel service) {
    return Column(
      children: service.providers.map((provider) {
        return InkWell(
          onTap: () => _onProviderTap(service, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                _providerIcon(provider['logo']),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider['name'],
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _providerIcon(String? logo) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: logo != null
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: Image.network(
                logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
              ),
            )
          : const Icon(Icons.apps, color: Color(0xFF1E88E5)),
    );
  }

  // ================= TAP =================
  void _onProviderTap(ServiceModel service, Map<String, dynamic> provider) {
    switch (service.id) {
      case 'telecom':
        Get.toNamed('/payTelecom', arguments: provider);
        break;
      case 'internet':
        Get.toNamed('/payInternet', arguments: provider);
        break;
      default:
        Get.snackbar(
          "Coming Soon",
          "${provider['name']} payment will be available soon",
        );
    }
  }
}
