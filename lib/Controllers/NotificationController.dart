import 'package:get/get.dart';
import '../Core/Network/NotificationApi.dart';
import 'package:intl/intl.dart';

class NotificationController extends GetxController {
  final NotificationApi _api = NotificationApi();

  var notifications = [].obs;
  var isLoading = false.obs;

  bool _isFetching = false; // ✅ REQUEST LOCK

  // 🔔 UNREAD COUNT
  int get unreadCount =>
      notifications.where((n) => n['read_at'] == null).length;

  // ❌ REMOVE auto fetch
  @override
  void onInit() {
    super.onInit();
    // fetchNotifications(); ❌ REMOVE THIS
  }

  // ✅ SAFE FETCH
  Future<void> fetchNotifications() async {
    if (_isFetching) return; // 🛑 Prevent duplicate calls
    _isFetching = true;

    try {
      isLoading.value = true;
      final response = await _api.getNotifications();
      notifications.value = response.data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  Future<void> markAsRead(String id) async {
    await _api.markAsRead(id);
    await fetchNotifications(); // ✅ Single refresh
  }

  Future<void> clearAll() async {
    await _api.clearAll();
    notifications.clear();
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _api.deleteOne(id);
      notifications.removeWhere((n) => n['id'] == id);
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete notification');
    }
  }

  bool isToday(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List todayNotifications() {
    return notifications.where((n) => isToday(n['created_at'])).toList();
  }

  List earlierNotifications() {
    return notifications.where((n) => !isToday(n['created_at'])).toList();
  }

  String formatTime(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat('hh:mm a').format(date);
  }

  var selectedType = 'all'.obs;

  List filteredNotifications() {
    if (selectedType.value == 'all') {
      return notifications;
    }
    return notifications
        .where((n) => n['data']['type'] == selectedType.value)
        .toList();
  }
}
