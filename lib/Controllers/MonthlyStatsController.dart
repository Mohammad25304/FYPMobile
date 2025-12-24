import 'dart:io';

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MonthlyStatsController extends GetxController {
  final Dio _dio = DioClient().getInstance();

  var isLoading = false.obs;
  var selectedCurrency = 'USD'.obs;
  var selectedYear = DateTime.now().year.obs;
  var selectedMonthIndex = 0.obs; // 0 = All, 1-12 = Jan-Dec

  // Month-over-Month comparison
  var incomeChange = 0.0.obs;
  var expenseChange = 0.0.obs;
  var balanceChange = 0.0.obs;

  var incomeChangePercent = 0.0.obs;
  var expenseChangePercent = 0.0.obs;
  var balanceChangePercent = 0.0.obs;

  var months = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> categoryBreakdown = <Map<String, dynamic>>[].obs;
  // Cached computed values
  final Map<int, Map<String, double>> _monthlyIncomeCache = {};
  final Map<int, Map<String, double>> _monthlyExpenseCache = {};

  double getCachedValue({
    required int monthIndex,
    required String currency,
    required bool isIncome,
  }) {
    final cache = isIncome ? _monthlyIncomeCache : _monthlyExpenseCache;

    if (cache[monthIndex] != null && cache[monthIndex]![currency] != null) {
      return cache[monthIndex]![currency]!;
    }

    final value = _extractValue(
      months[monthIndex],
      isIncome ? 'income' : 'expenses',
      currency,
    );

    cache.putIfAbsent(monthIndex, () => {});
    cache[monthIndex]![currency] = value;

    return value;
  }

  @override
  void onInit() {
    super.onInit();

    // 1️⃣ Initial load
    fetchMonthlyStats(year: selectedYear.value);

    // 2️⃣ Initial category breakdown
    fetchCategoryBreakdown(
      year: selectedYear.value,
      month: null,
      currency: selectedCurrency.value,
    );

    // 3️⃣ LISTENERS - Watch for changes
    ever(selectedMonthIndex, (value) {
      print('🔄 selectedMonthIndex changed to: $value');

      // Update category breakdown
      fetchCategoryBreakdown(
        year: selectedYear.value,
        month: selectedMonthIndex.value == 0 ? null : selectedMonthIndex.value,
        currency: selectedCurrency.value,
      );

      // Recalculate comparison
      calculateMonthComparison();
    });

    ever(selectedCurrency, (value) {
      print('🔄 selectedCurrency changed to: $value');

      // Update category breakdown
      fetchCategoryBreakdown(
        year: selectedYear.value,
        month: selectedMonthIndex.value == 0 ? null : selectedMonthIndex.value,
        currency: selectedCurrency.value,
      );

      // Recalculate comparison
      calculateMonthComparison();
    });

    ever(selectedYear, (value) {
      print('🔄 selectedYear changed to: $value');
      calculateMonthComparison();
    });
  }

  void calculateMonthComparison() {
    final currency = selectedCurrency.value;
    final selectedUiIndex = selectedMonthIndex.value;

    print('🔍 ====== calculateMonthComparison called ======');
    print('   selectedUiIndex: $selectedUiIndex');
    print('   months.length: ${months.length}');
    print('   currency: $currency');

    // Ignore "All" or insufficient data
    if (selectedUiIndex == 0) {
      print('   ❌ Resetting: "All" selected');
      _resetComparison();
      return;
    }

    if (months.length < 2) {
      print('   ❌ Resetting: insufficient data (need at least 2 months)');
      _resetComparison();
      return;
    }

    // selectedUiIndex: 1=Jan, 2=Feb, ..., 12=Dec
    // Convert to array index: Jan=0, Feb=1, etc.
    final currentIndex = selectedUiIndex - 1;

    if (currentIndex < 0 || currentIndex >= months.length) {
      print('   ❌ Resetting: Invalid index ($currentIndex out of range)');
      _resetComparison();
      return;
    }

    // Can't compare first month (no previous month)
    if (currentIndex == 0) {
      print('   ❌ Resetting: First month selected, nothing to compare');
      _resetComparison();
      return;
    }

    final current = months[currentIndex];
    final previous = months[currentIndex - 1];

    print('   ✅ Current month data: $current');
    print('   ✅ Previous month data: $previous');

    final currentIncome = getCachedValue(
      monthIndex: currentIndex,
      currency: currency,
      isIncome: true,
    );

    final previousIncome = getCachedValue(
      monthIndex: currentIndex - 1,
      currency: currency,
      isIncome: true,
    );

    final currentExpenses = getCachedValue(
      monthIndex: currentIndex,
      currency: currency,
      isIncome: false,
    );

    final previousExpenses = getCachedValue(
      monthIndex: currentIndex - 1,
      currency: currency,
      isIncome: false,
    );

    print(
      '   📊 Current Income: $currentIncome, Previous Income: $previousIncome',
    );
    print(
      '   📊 Current Expenses: $currentExpenses, Previous Expenses: $previousExpenses',
    );

    final currentBalance = currentIncome - currentExpenses;
    final previousBalance = previousIncome - previousExpenses;

    incomeChange.value = currentIncome - previousIncome;
    expenseChange.value = currentExpenses - previousExpenses;
    balanceChange.value = currentBalance - previousBalance;

    // Calculate percentages - if previous is 0 but current is not, show as 100% increase
    if (previousIncome == 0 && currentIncome > 0) {
      incomeChangePercent.value = 100.0; // New income from zero
    } else if (previousIncome == 0) {
      incomeChangePercent.value = 0.0;
    } else {
      incomeChangePercent.value = (incomeChange.value / previousIncome) * 100;
    }

    if (previousExpenses == 0 && currentExpenses > 0) {
      expenseChangePercent.value = 100.0; // New expenses from zero
    } else if (previousExpenses == 0) {
      expenseChangePercent.value = 0.0;
    } else {
      expenseChangePercent.value =
          (expenseChange.value / previousExpenses) * 100;
    }

    if (previousBalance == 0 && currentBalance != 0) {
      balanceChangePercent.value = 100.0; // Changed from zero
    } else if (previousBalance == 0) {
      balanceChangePercent.value = 0.0;
    } else {
      balanceChangePercent.value =
          (balanceChange.value / previousBalance) * 100;
    }

    print(
      '   📈 Income change: ${incomeChange.value} (${incomeChangePercent.value.toStringAsFixed(1)}%)',
    );
    print(
      '   📉 Expense change: ${expenseChange.value} (${expenseChangePercent.value.toStringAsFixed(1)}%)',
    );
    print(
      '   💰 Balance change: ${balanceChange.value} (${balanceChangePercent.value.toStringAsFixed(1)}%)',
    );
    print('🔍 ====== End calculateMonthComparison ======\n');
  }

  void _resetComparison() {
    print('   🔄 Resetting all comparison values to 0');
    incomeChange.value = 0;
    expenseChange.value = 0;
    balanceChange.value = 0;
    incomeChangePercent.value = 0;
    expenseChangePercent.value = 0;
    balanceChangePercent.value = 0;
  }

  double _extractValue(
    Map<String, dynamic> monthData,
    String key,
    String currency,
  ) {
    final data = monthData[key];
    if (data is Map) {
      final value = (data[currency] ?? 0).toDouble();
      print('      _extractValue: $key[$currency] = $value');
      return value;
    }
    final value = (data ?? 0).toDouble();
    print('      _extractValue: $key = $value (not a map)');
    return value;
  }

  Future<void> fetchMonthlyStats({int? year}) async {
    try {
      isLoading.value = true;

      final response = await _dio.get(
        'wallet/monthly-stats',
        queryParameters: {'year': year ?? selectedYear.value},
      );

      clearCache(); // ✅ MOVE HERE

      months.assignAll(
        List<Map<String, dynamic>>.from(response.data['months']),
      );

      calculateMonthComparison();
    } catch (e) {
      print('❌ Error fetching monthly stats: $e');
      Get.snackbar('Error', 'Failed to load monthly stats');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategoryBreakdown({
    required int year,
    int? month,
    required String currency,
  }) async {
    try {
      print(
        '🔍 Fetching category breakdown: year=$year, month=$month, currency=$currency',
      );

      final response = await _dio.get(
        'monthly/category-breakdown',
        queryParameters: {'year': year, 'month': month, 'currency': currency},
      );

      final raw = List<Map<String, dynamic>>.from(
        response.data['categories'] ?? [],
      );

      // 🎨 Category color map
      final colorMap = {
        'transfer': '0xFF6366F1',
        'exchange': '0xFFF59E0B',
        'send': '0xFF10B981',
        'receive': '0xFF22C55E',
        'bill': '0xFFEF4444',
      };

      categoryBreakdown.assignAll(
        raw.map((c) {
          final name = c['category']?.toString() ?? 'Other';

          return {
            'category': name,
            'amount': (c['total'] ?? 0).toDouble(), // ✅ KEY FIX
            'color': colorMap[name] ?? '0xFF94A3B8', // fallback color
          };
        }).toList(),
      );

      print(
        '✅ Category breakdown fetched: ${categoryBreakdown.length} categories',
      );
    } catch (e) {
      print('❌ Error fetching category breakdown: $e');
      categoryBreakdown.clear();
    }
  }

  // Future<void> exportMonthlyReport() async {
  //   try {
  //     final year = selectedYear.value;
  //     final currency = selectedCurrency.value;

  //     final response = await _dio.get(
  //       'wallet/export/monthly',
  //       queryParameters: {'year': year, 'currency': currency},
  //       options: Options(responseType: ResponseType.bytes),
  //     );

  //     // Save file locally
  //     final directory = await getApplicationDocumentsDirectory();
  //     final filePath =
  //         '${directory.path}/monthly_report_${year}_${currency}.csv';

  //     final file = File(filePath);
  //     await file.writeAsBytes(response.data);

  //     Get.snackbar(
  //       'Export Complete',
  //       'Saved to $filePath',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } catch (e) {
  //     Get.snackbar('Export Failed', 'Unable to export monthly report');
  //   }
  // }
  Future<void> exportMonthlyReport() async {
    try {
      final year = selectedYear.value;
      final currency = selectedCurrency.value;
      final month = selectedMonthIndex.value == 0
          ? null
          : selectedMonthIndex.value;

      final dir = await getExternalStorageDirectory();
      final folder = Directory('${dir!.path}/CashPilot');

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final filePath =
          '${folder.path}/monthly_report_${year}_${month ?? "all"}_$currency.csv';

      final response = await _dio.download(
        'wallet/export/monthly',
        filePath,
        queryParameters: {
          'year': year,
          'currency': currency,
          if (month != null) 'month': month,
        },
      );

      if (response.statusCode == 200) {
        await Share.shareXFiles([
          XFile(filePath),
        ], text: '📊 Monthly Financial Report ($currency)');
      }
    } catch (e) {
      print('❌ CSV Export Error: $e');
      Get.snackbar('Error', 'Failed to export CSV');
    }
  }

  Future<void> exportMonthlyPdf() async {
    try {
      final year = selectedYear.value;
      final currency = selectedCurrency.value;
      final month = selectedMonthIndex.value == 0
          ? null
          : selectedMonthIndex.value;

      final dir = await getExternalStorageDirectory();
      final folder = Directory('${dir!.path}/CashPilot');

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final filePath =
          '${folder.path}/monthly_report_${year}_${month ?? "all"}_$currency.pdf';

      final response = await _dio.download(
        'wallet/export/monthly-pdf',
        filePath,
        queryParameters: {
          'year': year,
          'currency': currency,
          if (month != null) 'month': month,
        },
      );

      if (response.statusCode == 200) {
        await Share.shareXFiles([
          XFile(filePath),
        ], text: '📊 Monthly Financial Report ($currency)');
      }
    } catch (e) {
      print('❌ PDF Export Error: $e');
      Get.snackbar('Error', 'Failed to export PDF');
    }
  }

  Future<void> _saveFileToDownloads({
    required List<int> bytes,
    required String fileName,
  }) async {
    final directory = await getExternalStorageDirectory();

    if (directory == null) {
      Get.snackbar('Error', 'Storage not available');
      return;
    }

    final downloadsDir = Directory('${directory.path}/CashPilot');

    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }

    final file = File('${downloadsDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    Get.snackbar(
      'PDF Saved',
      'Saved in CashPilot folder',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void clearCache() {
    _monthlyIncomeCache.clear();
    _monthlyExpenseCache.clear();
  }
}
