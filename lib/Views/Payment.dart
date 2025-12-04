import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/PaymentController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Views/Wallet.dart';

class Payment extends GetView<PaymentController> {
  Payment({super.key});

  final controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    controller.fetchPayments();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "No Payments Yet",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your payment history will appear here",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.payments.length,
          itemBuilder: (context, index) {
            final item = controller.payments[index];
            final bool isCredit = item["type"] == "credit";

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPaymentCard(context, item, isCredit),
            );
          },
        );
      }),
      bottomNavigationBar: Container(
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
          currentIndex: 2,
          selectedItemColor: const Color(0xFF1E88E5),
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          onTap: (index) {
            switch (index) {
              case 0:
                Get.back();
                break;
              case 1:
                Get.put(WalletController());
                Get.off(() => Wallet());
                break;
              case 2:
                // Already on Payments page
                break;
              case 3:
                // New page
                break;
              case 4:
                // New page
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
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map item, bool isCredit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Add tap action if needed
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCredit ? Colors.green[50] : Colors.red[50],
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isCredit ? Colors.green[600] : Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"] ?? "Transaction",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["transacted_at"] ?? "",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${item["currency"] ?? ""} ${item["amount"] ?? ""}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isCredit ? Colors.green[600] : Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isCredit ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCredit ? "Credit" : "Debit",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isCredit ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
