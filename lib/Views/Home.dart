import 'package:cashpilot/Controllers/PaymentController.dart';
import 'package:cashpilot/Views/Payment.dart';
import 'package:cashpilot/Views/Wallet.dart';
import 'package:cashpilot/Controllers/WalletController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/HomeController.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.logout,
          icon: const Icon(Icons.logout),
        ),
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
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              Text(
                controller.userName.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                // TODO: notifications page
              },
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                //profile page
              },
              icon: const Icon(Icons.person_outline, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWalletCard(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 28),
                      _buildServicesSection(),
                      const SizedBox(height: 28),
                      _buildRecentTransactions(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
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
          currentIndex: 0,
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
                //0 is the home page
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
                //New page
                break;
              case 4:
                //New page
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
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
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
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'CashPilot',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () => Text(
                        _getFormattedBalance(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => _buildCurrencySelector()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Income',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Obx(
                                  () => Text(
                                    _formatAmount(controller.totalIncome.value),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expenses',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Obx(
                                  () => Text(
                                    _formatAmount(
                                      controller.totalExpenses.value,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedCurrency.value,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 20,
          ),
          dropdownColor: const Color(0xFF1565C0),
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          items: const [
            DropdownMenuItem(value: 'USD', child: Text('USD')),
            DropdownMenuItem(value: 'EUR', child: Text('EUR')),
            DropdownMenuItem(value: 'LBP', child: Text('LBP')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.selectedCurrency.value = value;
            }
          },
        ),
      ),
    );
  }

  String _getFormattedBalance() {
    final currency = controller.selectedCurrency.value;
    double balance;
    String symbol;

    // Get balance directly from controller based on selected currency
    switch (currency) {
      case 'EUR':
        balance = controller.euroBalance.value;
        symbol = '€';
        break;
      case 'LBP':
        balance = controller.lbpBalance.value;
        symbol = 'LL';
        break;
      case 'USD':
      default:
        balance = controller.usdBalance.value;
        symbol = '\$';
    }

    // Format based on currency
    if (currency == 'LBP') {
      return '$symbol${balance.toStringAsFixed(0)}';
    } else {
      return '$symbol${balance.toStringAsFixed(2)}';
    }
  }

  String _formatAmount(double amount) {
    final currency = controller.selectedCurrency.value;

    switch (currency) {
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'LBP':
        return 'LL${amount.toStringAsFixed(0)}';
      case 'USD':
      default:
        return '\$${amount.toStringAsFixed(2)}';
    }
  }

  Widget _buildQuickActions() {
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
            _quickActionButton(
              icon: Icons.send_rounded,
              label: 'Send',
              color: const Color(0xFF1E88E5),
              onTap: () {
                Get.toNamed('/sendMoney');
              },
            ),
            const SizedBox(width: 12),
            _quickActionButton(
              icon: Icons.receipt_long_rounded,
              label: 'Pay Bills',
              color: const Color(0xFFFF6B6B),
              onTap: () {},
            ),
            const SizedBox(width: 12),
            _quickActionButton(
              icon: Icons.add_rounded,
              label: 'Receive',
              color: const Color(0xFF4CAF50),
              onTap: () {
                Get.toNamed('/addMoney');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.services.length > 6
                ? 6
                : controller.services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final service = controller.services[index];
              return _serviceTile(service['name']!, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _serviceTile(String name, int index) {
    final colors = [
      const Color(0xFF1E88E5),
      const Color(0xFFFF6B6B),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
    ];
    final color = colors[index % colors.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.grid_view_rounded, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.recentTransactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent transactions',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentTransactions.length,
            itemBuilder: (context, index) {
              final tx = controller.recentTransactions[index];
              final isDebit = (tx['type'] ?? 'debit') == 'debit';
              final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDebit
                                  ? const Color(0xFFFFEBEE)
                                  : const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDebit
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: isDebit
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF43A047),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx['title'] ?? 'Transaction',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tx['date'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            (isDebit ? '-' : '+') +
                                '\$${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDebit
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF43A047),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
