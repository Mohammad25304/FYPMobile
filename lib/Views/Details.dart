import 'package:cashpilot/Bindings/ProfileBinding.dart';
import 'package:cashpilot/Controllers/HomeController.dart';
import 'package:cashpilot/Controllers/PaymentController.dart';
import 'package:cashpilot/Controllers/ServiceController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Controllers/DetailsController.dart';
import 'package:cashpilot/Views/DetailsView.dart';
import 'package:cashpilot/Views/Home.dart';
import 'package:cashpilot/Views/Payment.dart';
import 'package:cashpilot/Views/Profile.dart';
import 'package:cashpilot/Views/Service.dart';
import 'package:cashpilot/Views/Wallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Details extends GetView<DetailsController> {
  const Details({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNav(),
      body: Obx(
        () => controller.detailsList.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 100),
                child: _buildEmptyState(),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.detailsList.length,
                itemBuilder: (context, index) {
                  final item = controller.detailsList[index];

                  // Icon logic ONLY (no navigation here)
                  IconData icon = Icons.description_rounded;
                  switch (item.keyName) {
                    case 'profile':
                      icon = Icons.person_rounded;
                      break;
                    case 'notification':
                      icon = Icons.notifications_rounded;
                      break;
                    case 'about_us':
                      icon = Icons.info_rounded;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildUnifiedCard(
                      icon: icon,
                      title: item.title,
                      description: item.description,
                      gradientColors: const [
                        Color(0xFF1E88E5),
                        Color(0xFF1565C0),
                      ],
                      onTap: () {
                        // ✅ Navigation ONLY happens here
                        if (item.keyName == 'profile') {
                          Get.to(
                            () => const Profile(),
                            binding: ProfileBinding(),
                          );
                        } else {
                          Get.to(
                            () => DetailsViewPage(
                              title: item.title,
                              keyName: item.keyName,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  /* ================= APP BAR ================= */

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Manage your information',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /* ================= BOTTOM NAV ================= */

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 4,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.put(HomeController());
              Get.to(() => Home());
              break;
            case 1:
              Get.put(WalletController());
              Get.to(() => Wallet());
              break;
            case 2:
              Get.put(PaymentController());
              Get.to(() => Payment());
              break;
            case 3:
              Get.put(ServiceController());
              Get.to(() => Service());
              break;
            case 4:
              // Current page
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment_rounded),
            label: "Payments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            activeIcon: Icon(Icons.apps_rounded),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: "Details",
          ),
        ],
      ),
    );
  }

  /* ================= CARD ================= */

  Widget _buildUnifiedCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= EMPTY STATE ================= */

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: Color(0xFF1E88E5),
          ),
          const SizedBox(height: 20),
          const Text(
            'No additional details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your details will appear here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
