import 'package:cashpilot/Controllers/DetailsController.dart';
import 'package:cashpilot/Controllers/HomeController.dart';
import 'package:cashpilot/Controllers/ServiceController.dart';
import 'package:cashpilot/Views/Details.dart';
import 'package:cashpilot/Views/Home.dart';
import 'package:cashpilot/Views/Service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/PaymentController.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Views/Wallet.dart';
import 'package:intl/intl.dart';

class Payment extends GetView<PaymentController> {
  Payment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Payment History",
          style: TextStyle(color: Color(0xFFF5F7FA)),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPayments,
          color: const Color(0xFF1E88E5),
          child: Column(
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPaymentCard(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

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
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF1E88E5),
        backgroundColor: const Color(0xFFE3F2FD),
        onSelected: (_) => controller.changeRangeType(value),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
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
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map item) {
    // ✅ Use type from backend (debit/credit)
    final bool isDebit = item['type'] == 'debit';
    final String title = item['title'] ?? 'Transaction';
    final String category = item['category'] ?? 'transfer';

    // ✅ Color and icon based on TYPE (not category)
    final Color mainColor = isDebit ? Colors.red : Colors.green;
    final IconData icon = isDebit
        ? Icons
              .arrow_upward_rounded // ↑ Money leaving (RED)
        : Icons.arrow_downward_rounded; // ↓ Money coming in (GREEN)

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ✅ ICON (based on type)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mainColor.withOpacity(0.1),
              ),
              child: Icon(icon, color: mainColor),
            ),

            const SizedBox(width: 16),

            // TITLE + DATE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'yyyy-MM-dd',
                    ).format(DateTime.parse(item["transacted_at"])),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),

            // AMOUNT + BADGE
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ✅ Amount sign based on type
                Text(
                  "${isDebit ? '-' : '+'}${item["currency"]} ${item["amount"].toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 4),
                // ✅ Badge text based on category
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: mainColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
              Get.put(HomeController());
              Get.to(() => Home());
              break;
            case 1:
              Get.put(WalletController());
              Get.to(() => Wallet());
              break;
            case 2:
              break;
            case 3:
              Get.put(ServiceController());
              Get.to(() => Service());
              break;
            case 4:
              Get.put(DetailsController());
              Get.to(Details());
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
            icon: Icon(Icons.menu_outlined),
            activeIcon: Icon(Icons.menu_rounded),
            label: "Details",
          ),
        ],
      ),
    );
  }
}
