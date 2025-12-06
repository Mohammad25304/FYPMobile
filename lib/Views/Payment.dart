import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/PaymentController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Views/Wallet.dart';

class Payment extends GetView<PaymentController> {
  Payment({super.key});

  // Register the controller
  final PaymentController controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    // Load payments (you can move this to controller.onInit if you prefer)
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

        return Column(
          children: [
            _buildFilterHeader(context),
            const Divider(height: 1),
            Expanded(
              child: controller.payments.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
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
                    ),
            ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ---------------- FILTER HEADER (Calendar + Day/Week/Month/Year) ----------------

  Widget _buildFilterHeader(BuildContext context) {
    return Obx(() {
      final date = controller.selectedDate.value;
      final range = controller.selectedRangeType.value;

      String rangeLabel;
      switch (range) {
        case 'day':
          rangeLabel = "Day";
          break;
        case 'week':
          rangeLabel = "Week";
          break;
        case 'month':
          rangeLabel = "Month";
          break;
        case 'year':
          rangeLabel = "Year";
          break;
        default:
          rangeLabel = "Day";
      }

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: label + date + calendar icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filter by date",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$rangeLabel view · $formattedDate",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month_rounded),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      controller.changeSelectedDate(picked);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Chips for Day / Week / Month / Year
            Wrap(
              spacing: 8,
              children: [
                _buildRangeChip("Day", "day"),
                _buildRangeChip("Week", "week"),
                _buildRangeChip("Month", "month"),
                _buildRangeChip("Year", "year"),
              ],
            ),
          ],
        ),
<<<<<<< HEAD
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
              label: "Details",
            ),
          ],
=======
      );
    });
  }

  Widget _buildRangeChip(String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedRangeType.value == value;

      return ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
>>>>>>> e9dc32be84c15b18d6604bb2635fba7a23aa200b
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF1E88E5),
        backgroundColor: const Color(0xFFE3F2FD),
        onSelected: (_) => controller.changeRangeType(value),
      );
    });
  }

  // -------------------- EMPTY STATE --------------------

  Widget _buildEmptyState(BuildContext context) {
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

  // -------------------- PAYMENT CARD --------------------

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

  // -------------------- BOTTOM NAV BAR --------------------

  Widget _buildBottomNavBar() {
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
              // Already on Payments
              break;
            case 3:
              // Services page
              break;
            case 4:
              // Profile / Details page
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
    );
  }
}
