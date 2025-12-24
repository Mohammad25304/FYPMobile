import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cashpilot/Controllers/MonthlyStatsController.dart';

class MonthlyStatsPage extends StatelessWidget {
  const MonthlyStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.find<MonthlyStatsController>(); // Changed from Get.put()

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Monthly Statistics',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // ================= CURRENCY SELECT =================
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(
              () => DropdownButton<String>(
                value: controller.selectedCurrency.value,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'LBP', child: Text('LBP')),
                ],
                onChanged: (v) => controller.selectedCurrency.value = v!,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.download_rounded, color: Color(0xFF6366F1)),
            onPressed: () {
              Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                        title: const Text('Export as PDF'),
                        onTap: () {
                          Get.back();
                          controller.exportMonthlyPdf();
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.table_chart,
                          color: Colors.green,
                        ),
                        title: const Text('Export as CSV'),
                        onTap: () {
                          Get.back();
                          controller.exportMonthlyReport();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF6366F1),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Loading statistics...',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : controller.months.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        size: 64,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No data available',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start tracking your finances to see statistics',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildYearSelector(controller),
                    const SizedBox(height: 20),
                    _buildMonthSelector(controller),
                    const SizedBox(height: 24),
                    _buildSummaryCards(controller),
                    const SizedBox(height: 24),
                    _buildChartCard(controller),
                    const SizedBox(height: 24),
                    _buildCategoryBreakdown(controller),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildYearSelector(MonthlyStatsController controller) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Select Year',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            DropdownButton<int>(
              value: controller.selectedYear.value,
              underline: const SizedBox(),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF6366F1),
              ),
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              items: years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (year) {
                if (year != null) {
                  controller.selectedYear.value = year;
                  controller.fetchMonthlyStats(year: year);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(MonthlyStatsController controller) {
    final months = [
      'All',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Obx(() {
      final selectedIndex = controller.selectedMonthIndex.value;

      return SizedBox(
        height: 50,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: months.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () => controller.selectedMonthIndex.value = index,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF6366F1).withOpacity(0.3)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: isSelected ? 12 : 8,
                      offset: Offset(0, isSelected ? 4 : 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    months[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSummaryCards(MonthlyStatsController controller) {
    return Obx(() {
      final currency = controller.selectedCurrency.value;
      final selectedIndex = controller.selectedMonthIndex.value;
      final monthsList = controller.months;

      double totalIncome = 0;
      double totalExpenses = 0;

      if (selectedIndex == 0) {
        for (var month in monthsList) {
          totalIncome += _extractValue(month, 'income', currency);
          totalExpenses += _extractValue(month, 'expenses', currency);
        }
      } else {
        if (selectedIndex - 1 < monthsList.length) {
          final month = monthsList[selectedIndex - 1];
          totalIncome = _extractValue(month, 'income', currency);
          totalExpenses = _extractValue(month, 'expenses', currency);
        }
      }

      final balance = totalIncome - totalExpenses;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // ================= INCOME =================
            Expanded(
              child: Column(
                children: [
                  _buildSummaryCard(
                    'Total Income',
                    totalIncome,
                    currency,
                    const Color(0xFF10B981),
                    Icons.trending_up_rounded,
                  ),
                  const SizedBox(height: 4),
                  // ✅ UPDATED INCOME COMPARISON
                  Obx(() {
                    final changePercent = controller.incomeChangePercent.value;
                    final changeAmount = controller.incomeChange.value;
                    final selectedIndex = controller.selectedMonthIndex.value;

                    // Don't show for "All" or first month
                    if (selectedIndex == 0 || selectedIndex == 1) {
                      return const SizedBox();
                    }

                    // Don't show if no change at all
                    if (changePercent == 0 && changeAmount == 0) {
                      return const SizedBox();
                    }

                    // If percentage is available and meaningful
                    if (changePercent != 0) {
                      return Text(
                        changePercent > 0
                            ? '↑ ${changePercent.toStringAsFixed(1)}% vs last month'
                            : '↓ ${changePercent.abs().toStringAsFixed(1)}% vs last month',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: changePercent > 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      );
                    }

                    // If no percentage but there's a change (from zero)
                    return Text(
                      '↑ ${_formatCurrency(changeAmount.abs())} $currency from \$0',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ================= EXPENSES =================
            Expanded(
              child: Column(
                children: [
                  _buildSummaryCard(
                    'Total Expenses',
                    totalExpenses,
                    currency,
                    const Color(0xFFEF4444),
                    Icons.trending_down_rounded,
                  ),
                  const SizedBox(height: 4),
                  // ✅ UPDATED EXPENSES COMPARISON
                  Obx(() {
                    final changePercent = controller.expenseChangePercent.value;
                    final changeAmount = controller.expenseChange.value;
                    final selectedIndex = controller.selectedMonthIndex.value;

                    if (selectedIndex == 0 || selectedIndex == 1) {
                      return const SizedBox();
                    }

                    if (changePercent == 0 && changeAmount == 0) {
                      return const SizedBox();
                    }

                    if (changePercent != 0) {
                      return Text(
                        changePercent > 0
                            ? '↑ ${changePercent.toStringAsFixed(1)}% vs last month'
                            : '↓ ${changePercent.abs().toStringAsFixed(1)}% vs last month',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          // For expenses: UP is bad (red), DOWN is good (green)
                          color: changePercent > 0
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                        ),
                      );
                    }

                    return Text(
                      '↑ ${_formatCurrency(changeAmount.abs())} $currency from \$0',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ================= BALANCE =================
            Expanded(
              child: Column(
                children: [
                  _buildSummaryCard(
                    'Balance',
                    balance,
                    currency,
                    balance >= 0
                        ? const Color(0xFF6366F1)
                        : const Color(0xFFF59E0B),
                    Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(height: 4),
                  // ✅ UPDATED BALANCE COMPARISON
                  Obx(() {
                    final changePercent = controller.balanceChangePercent.value;
                    final changeAmount = controller.balanceChange.value;
                    final selectedIndex = controller.selectedMonthIndex.value;

                    if (selectedIndex == 0 || selectedIndex == 1) {
                      return const SizedBox();
                    }

                    if (changePercent == 0 && changeAmount == 0) {
                      return const SizedBox();
                    }

                    if (changePercent != 0) {
                      return Text(
                        changePercent > 0
                            ? '↑ ${changePercent.toStringAsFixed(1)}% vs last month'
                            : '↓ ${changePercent.abs().toStringAsFixed(1)}% vs last month',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: changePercent > 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      );
                    }

                    return Text(
                      changeAmount > 0
                          ? '↑ ${_formatCurrency(changeAmount.abs())} $currency better'
                          : '↓ ${_formatCurrency(changeAmount.abs())} $currency worse',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: changeAmount > 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    String currency,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${_formatCurrency(amount)} $currency',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(MonthlyStatsController controller) {
    print('🧩 CATEGORY BREAKDOWN UI DATA: ${controller.categoryBreakdown}');

    return Obx(() {
      final categories = controller.categoryBreakdown;

      if (categories.isEmpty) {
        return const SizedBox();
      }

      final total = categories.fold<double>(
        0,
        (sum, c) => sum + (c['amount'] ?? 0).toDouble(),
      );

      if (total == 0) {
        return const SizedBox();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  sections: categories.map((c) {
                    final value = (c['amount'] ?? 0).toDouble();
                    final percent = (value / total) * 100;

                    return PieChartSectionData(
                      value: value,
                      title: '${percent.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      color: Color(int.parse(c['color'] ?? '0xFF6366F1')),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categories.map((c) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(int.parse(c['color'] ?? '0xFF6366F1')),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      c['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChartCard(MonthlyStatsController controller) {
    return Obx(() {
      final selectedIndex = controller.selectedMonthIndex.value;
      final monthName = selectedIndex == 0
          ? 'All Months'
          : _getMonthName(selectedIndex);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  monthName,
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF10B981), 'Income'),
                const SizedBox(width: 32),
                _buildLegendItem(const Color(0xFFEF4444), 'Expenses'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 320,
              child: selectedIndex == 0
                  ? _buildAllMonthsChart(controller)
                  : _buildSingleMonthChart(controller),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAllMonthsChart(MonthlyStatsController controller) {
    return Obx(() {
      final currency = controller.selectedCurrency.value;
      final monthsList = controller.months;
      final itemCount = monthsList.length;

      if (itemCount == 0) {
        return const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        );
      }

      final barWidth = itemCount > 8 ? 10.0 : 14.0;
      final barsSpace = itemCount > 8 ? 3.0 : 4.0;

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _calculateMaxY(monthsList, currency),
          barGroups: List.generate(itemCount, (index) {
            final month = monthsList[index];
            final income = _extractValue(month, 'income', currency);
            final expenses = _extractValue(month, 'expenses', currency);

            return BarChartGroupData(
              x: index,
              barsSpace: barsSpace,
              barRods: [
                BarChartRodData(
                  toY: income,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: barWidth,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                BarChartRodData(
                  toY: expenses,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: barWidth,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= monthsList.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _getMonthLabel(monthsList[index]),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: _calculateInterval(monthsList, currency),
                getTitlesWidget: (value, _) {
                  return Text(
                    _formatAmount(value),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateInterval(monthsList, currency),
            getDrawingHorizontalLine: (value) {
              return FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: const Color(0xFF1E293B),
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              tooltipMargin: 12,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final month = monthsList[group.x.toInt()];
                final label = rodIndex == 0 ? 'Income' : 'Expenses';
                final color = rodIndex == 0
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444);
                return BarTooltipItem(
                  '${_getMonthLabel(month)}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '$label\n',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '${_formatCurrency(rod.toY)} $currency',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSingleMonthChart(MonthlyStatsController controller) {
    return Obx(() {
      final currency = controller.selectedCurrency.value;
      final monthIndex = controller.selectedMonthIndex.value - 1;
      final monthsList = controller.months;

      if (monthIndex < 0 || monthIndex >= monthsList.length) {
        return const Center(
          child: Text(
            'No data available for this month',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        );
      }

      final month = monthsList[monthIndex];
      final income = _extractValue(month, 'income', currency);
      final expenses = _extractValue(month, 'expenses', currency);
      final maxValue = income > expenses ? income : expenses;

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: maxValue * 1.2,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barsSpace: 20,
              barRods: [
                BarChartRodData(
                  toY: income,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 60,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                BarChartRodData(
                  toY: expenses,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 60,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 40),
                          Text(
                            'Income',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 80),
                          Text(
                            'Expenses',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, _) {
                  return Text(
                    _formatAmount(value),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: const Color(0xFF1E293B),
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = rodIndex == 0 ? 'Income' : 'Expenses';
                final color = rodIndex == 0
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444);
                return BarTooltipItem(
                  '$label\n',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '${_formatCurrency(rod.toY)} $currency',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _extractValue(
    Map<String, dynamic> month,
    String key,
    String currency,
  ) {
    try {
      final data = month[key];
      if (data == null) return 0.0;
      if (data is Map) {
        return (data[currency] ?? 0).toDouble();
      }
      return (data as num).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  String _getMonthLabel(Map<String, dynamic> month) {
    try {
      final monthStr = month['month']?.toString() ?? '';
      return monthStr.length >= 3 ? monthStr.substring(0, 3) : monthStr;
    } catch (e) {
      return '';
    }
  }

  String _getMonthName(int index) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return index >= 0 && index < months.length ? months[index] : '';
  }

  double _calculateMaxY(
    List<Map<String, dynamic>> monthsList,
    String currency,
  ) {
    double max = 0;
    for (var month in monthsList) {
      final income = _extractValue(month, 'income', currency);
      final expenses = _extractValue(month, 'expenses', currency);
      if (income > max) max = income;
      if (expenses > max) max = expenses;
    }
    return max * 1.15;
  }

  double _calculateInterval(
    List<Map<String, dynamic>> monthsList,
    String currency,
  ) {
    final maxY = _calculateMaxY(monthsList, currency);
    if (maxY <= 0) return 1;
    return (maxY / 5).ceilToDouble();
  }

  String _formatAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatCurrency(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }
}
