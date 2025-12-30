import 'package:cashpilot/Controllers/DetailsController.dart';
import 'package:cashpilot/Controllers/HomeController.dart';
import 'package:cashpilot/Controllers/PaymentController.dart';
import 'package:cashpilot/Controllers/ServiceController.dart';
import 'package:cashpilot/Views/Details.dart';
import 'package:cashpilot/Views/Home.dart';
import 'package:cashpilot/Views/Payment.dart';
import 'package:cashpilot/Views/Service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:cashpilot/Views/SendCashPickup.dart';
import 'package:cashpilot/Bindings/CashPickupBinding.dart';

class Wallet extends GetView<WalletController> {
  Wallet({super.key});
  final RxMap<String, bool> expandedDays = <String, bool>{}.obs;

  @override
  Widget build(BuildContext context) {
    // ❌ REMOVE this (it runs on every rebuild and can break your list)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.fetchTransactions();
    // });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        iconTheme: const IconThemeData(color: Colors.white),
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
          'My Wallet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                // ✅ refresh wallet after returning from Payments
                Get.to(() => Payment())?.then((_) => controller.refreshAll());
              },
              icon: const Icon(Icons.history_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _walletCard(),
              const SizedBox(height: 28),
              _quickStats(),
              const SizedBox(height: 28),
              _actionButtons(),
              const SizedBox(height: 32),
              _recentTransactions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
              break;
            case 2:
              Get.put(PaymentController());
              Get.to(() => Payment())?.then((_) => controller.refreshAll());
              break;
            case 3:
              Get.put(ServiceController());
              Get.to(Service());
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

  Widget _walletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Available Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => PopupMenuButton<String>(
                      onSelected: (String value) {
                        controller.changeCurrency(value);
                      },
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              controller.selectedCurrency.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            _buildCurrencyMenuItem(
                              'USD',
                              'US Dollar',
                              controller.usdBalance.value,
                            ),
                            _buildCurrencyMenuItem(
                              'EUR',
                              'Euro',
                              controller.eurBalance.value,
                            ),
                            _buildCurrencyMenuItem(
                              'LBP',
                              'Lebanese Pound',
                              controller.lbpBalance.value,
                            ),
                          ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(
                () => Text(
                  "${controller.currencySymbol}${_formatBalance(controller.currentBalance)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  controller.currencyName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  String _formatBalance(double balance) {
    if (controller.selectedCurrency.value == 'LBP') {
      return balance
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return balance.toStringAsFixed(2);
  }

  PopupMenuItem<String> _buildCurrencyMenuItem(
    String code,
    String name,
    double balance,
  ) {
    String symbol = code == 'USD' ? '\$' : (code == 'EUR' ? '€' : 'LL');
    String formattedBalance = code == 'LBP'
        ? balance
              .toStringAsFixed(0)
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )
        : balance.toStringAsFixed(2);

    return PopupMenuItem<String>(
      value: code,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Text(
              '$symbol$formattedBalance',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E88E5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Total Income',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(
                  () => Text(
                    '${controller.selectedSymbol}${controller.selectedIncome.toStringAsFixed(controller.selectedCurrency.value == "LBP" ? 0 : 2)}',
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Total Expenses',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(
                  () => Text(
                    '${controller.selectedSymbol}${controller.selectedExpenses.toStringAsFixed(controller.selectedCurrency.value == "LBP" ? 0 : 2)}',
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _walletButton(
              icon: Icons.add_rounded,
              label: "Receive",
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
              ),
              onTap: () {
                Get.toNamed('/addMoney');
              },
            ),
            const SizedBox(width: 12),
            _walletButton(
              icon: Icons.arrow_upward_rounded,
              label: "Send",
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              ),
              onTap: () {
                Get.toNamed('/sendMoney');
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _walletButton(
              icon: Icons.swap_horiz_rounded,
              label: "Transfer",
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
              ),
              onTap: () {
                Get.toNamed('/transferMoney');
              },
            ),
            const SizedBox(width: 12),
            _walletButton(
              icon: Icons.local_atm_rounded,
              label: "Send Cash",
              gradient: const LinearGradient(
                colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
              ),
              onTap: () {
                Get.to(
                  () => const SendCashPickup(),
                  binding: CashPickupBinding(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _walletButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentTransactions() {
    return Obx(() {
      if (controller.walletTransactions.isEmpty) {
        return const SizedBox.shrink();
      }

      // 🔒 LIMIT TO 5 TRANSACTIONS
      final limitedTx = controller.walletTransactions.take(5).toList();

      final groupedTx = groupByDay(limitedTx);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => Payment())?.then((_) => controller.refreshAll());
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grouped + collapsible
          ...groupedTx.entries.map((entry) {
            final isExpanded = expandedDays[entry.key] ?? true;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔽 DAY HEADER (CLICKABLE)
                InkWell(
                  onTap: () {
                    expandedDays[entry.key] = !isExpanded;
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E88E5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: const Color(0xFF64748B),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 TRANSACTIONS (COLLAPSIBLE)
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16),
                    child: Column(
                      children: entry.value.map((tx) {
                        final bool isDebit = tx['type'] == 'debit';
                        final double amount =
                            double.tryParse(tx['amount'].toString()) ?? 0.0;
                        final String currency = tx['currency'] ?? 'USD';

                        final symbol = currency == 'USD'
                            ? '\$'
                            : currency == 'EUR'
                            ? '€'
                            : 'LL';

                        final categoryIcon = _getCategoryIcon(
                          tx['category'] ?? 'transfer',
                        );
                        final categoryColor = _getCategoryColor(
                          tx['category'] ?? 'transfer',
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Optional: Show transaction details
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.grey[100]!,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Icon with category color background
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: categoryColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          categoryIcon,
                                          color: categoryColor,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Title & Category
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx['title'] ?? 'Transaction',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            _formatCategory(
                                              tx['category'] ?? 'transfer',
                                            ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Amount with sign
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${isDebit ? '−' : '+'}$symbol${amount.toStringAsFixed(currency == 'LBP' ? 0 : 2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: isDebit
                                                ? const Color(0xFFFF6B6B)
                                                : const Color(0xFF4CAF50),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          currency,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[400],
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
                      }).toList(),
                    ),
                  ),

                if (isExpanded) const SizedBox(height: 8),
              ],
            );
          }).toList(),
        ],
      );
    });
  }

  // Helper: Get category icon
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'transfer':
        return Icons.compare_arrows_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'withdrawal':
        return Icons.arrow_upward_rounded;
      case 'deposit':
        return Icons.arrow_downward_rounded;
      case 'cashpickup':
        return Icons.local_atm_rounded;
      case 'exchange':
        return Icons.swap_horiz_rounded;
      case 'fee':
        return Icons.receipt_long_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  // Helper: Get category color
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'transfer':
        return const Color(0xFF1E88E5);
      case 'payment':
        return const Color(0xFFFF9800);
      case 'withdrawal':
        return const Color(0xFFFF6B6B);
      case 'deposit':
        return const Color(0xFF4CAF50);
      case 'cashpickup':
        return const Color(0xFF673AB7);
      case 'exchange':
        return const Color(0xFF00BCD4);
      case 'fee':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF1E88E5);
    }
  }

  // Helper: Format category label
  String _formatCategory(String category) {
    switch (category.toLowerCase()) {
      case 'transfer':
        return 'Transfer';
      case 'payment':
        return 'Payment';
      case 'withdrawal':
        return 'Withdrawal';
      case 'deposit':
        return 'Deposit';
      case 'cashpickup':
        return 'Cash Pickup';
      case 'exchange':
        return 'Exchange';
      case 'fee':
        return 'Fee';
      default:
        return category;
    }
  }

  Map<String, List<Map<String, dynamic>>> groupByDay(
    List<Map<String, dynamic>> transactions,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final now = DateTime.now();

    for (final tx in transactions) {
      final dateStr = tx['date'] ?? '';
      if (dateStr.isEmpty) continue;

      final txDate = DateTime.tryParse(dateStr);
      if (txDate == null) continue;

      String key;
      final diff = now.difference(txDate).inDays;

      if (diff == 0) {
        key = 'Today';
      } else if (diff == 1) {
        key = 'Yesterday';
      } else {
        key = dateStr;
      }

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(tx);
    }

    return grouped;
  }
}
