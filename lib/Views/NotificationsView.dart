import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/NotificationController.dart';

class NotificationsView extends GetView<NotificationController> {
  const NotificationsView({super.key});

  IconData _icon(String type) {
    switch (type) {
      case 'transaction':
        return Icons.swap_horiz;
      case 'security':
        return Icons.lock_outline;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  Widget _filterChips(NotificationController controller) {
    final types = ['all', 'transaction', 'security', 'system'];

    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: types.map((type) {
            final isSelected = controller.selectedType.value == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(type.toUpperCase()),
                selected: isSelected,
                onSelected: (_) => controller.selectedType.value = type,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _notificationTile(Map n, Map data) {
    final controller = Get.find<NotificationController>();

    return Dismissible(
      key: ValueKey(n['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteNotification(n['id']),
      child: GestureDetector(
        onTap: () => controller.markAsRead(n['id']),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: n['read_at'] == null
                ? const Color(0xFFE3F2FD)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(_icon(data['type']), color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['message'],
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.formatTime(n['created_at']),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.clearAll,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== TODAY =====
              if (controller.todayNotifications().isNotEmpty) ...[
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                ...controller.todayNotifications().map((n) {
                  final data = n['data'];
                  return _notificationTile(n, data);
                }).toList(),

                const SizedBox(height: 24),
              ],

              // ===== EARLIER =====
              if (controller.earlierNotifications().isNotEmpty) ...[
                const Text(
                  'Earlier',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                ...controller.earlierNotifications().map((n) {
                  final data = n['data'];
                  return _notificationTile(n, data);
                }).toList(),
              ],
            ],
          ),
        );
      }),
    );
  }
}
