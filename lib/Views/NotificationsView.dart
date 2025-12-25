import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/NotificationController.dart';

class NotificationsView extends GetView<NotificationController> {
  const NotificationsView({super.key});

  IconData _icon(String type) {
    switch (type) {
      case 'transaction':
        return Icons.swap_horiz_rounded;
      case 'security':
        return Icons.shield_outlined;
      case 'system':
        return Icons.settings_suggest_outlined;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'transaction':
        return const Color(0xFF10B981);
      case 'security':
        return const Color(0xFFEF4444);
      case 'system':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  Color _backgroundColor(String type) {
    switch (type) {
      case 'transaction':
        return const Color(0xFFECFDF5);
      case 'security':
        return const Color(0xFFFEF2F2);
      case 'system':
        return const Color(0xFFEFF6FF);
      default:
        return const Color(0xFFF5F3FF);
    }
  }

  Widget _filterChips(NotificationController controller) {
    final filters = [
      {'type': 'all', 'label': 'All', 'icon': Icons.grid_view_rounded},
      {
        'type': 'transaction',
        'label': 'Transactions',
        'icon': Icons.swap_horiz_rounded,
      },
      {'type': 'security', 'label': 'Security', 'icon': Icons.shield_outlined},
      {
        'type': 'system',
        'label': 'System',
        'icon': Icons.settings_suggest_outlined,
      },
    ];

    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: filters.map((filter) {
            final isSelected = controller.selectedType.value == filter['type'];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilterChip(
                avatar: Icon(
                  filter['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
                label: Text(
                  filter['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
                selected: isSelected,
                onSelected: (_) =>
                    controller.selectedType.value = filter['type'] as String,
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF3B82F6),
                checkmarkColor: Colors.white,
                elevation: 0,
                pressElevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _notificationTile(Map n, Map data) {
    final controller = Get.find<NotificationController>();
    final isUnread = n['read_at'] == null;

    return Dismissible(
      key: ValueKey(n['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => controller.deleteNotification(n['id']),
      child: GestureDetector(
        onTap: () => controller.markAsRead(n['id']),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? const Color(0xFF3B82F6).withOpacity(0.3)
                  : const Color(0xFFE2E8F0),
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _backgroundColor(data['type']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _icon(data['type']),
                        color: _iconColor(data['type']),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['title'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3B82F6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data['message'],
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                              height: 1.4,
                              fontWeight: isUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                controller.formatTime(n['created_at']),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 56,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Well notify you when something arrives',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          Obx(
            () => controller.unreadCount > 0
                ? Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${controller.unreadCount} new',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
            onPressed: controller.notifications.isEmpty
                ? null
                : controller.clearAll,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredNotifs = controller.filteredNotifications();

        return Column(
          children: [
            const SizedBox(height: 16),
            _filterChips(controller),
            const SizedBox(height: 20),
            Expanded(
              child: filteredNotifs.isEmpty
                  ? _emptyState()
                  : RefreshIndicator(
                      onRefresh: controller.fetchNotifications,
                      color: const Color(0xFF3B82F6),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // TODAY
                          if (controller.todayNotifications().where((n) {
                            if (controller.selectedType.value == 'all')
                              return true;
                            return n['data']['type'] ==
                                controller.selectedType.value;
                          }).isNotEmpty) ...[
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'TODAY',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...controller
                                .todayNotifications()
                                .where((n) {
                                  if (controller.selectedType.value == 'all')
                                    return true;
                                  return n['data']['type'] ==
                                      controller.selectedType.value;
                                })
                                .map((n) {
                                  final data = n['data'];
                                  return _notificationTile(n, data);
                                })
                                .toList(),
                            const SizedBox(height: 28),
                          ],

                          // EARLIER
                          if (controller.earlierNotifications().where((n) {
                            if (controller.selectedType.value == 'all')
                              return true;
                            return n['data']['type'] ==
                                controller.selectedType.value;
                          }).isNotEmpty) ...[
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF94A3B8),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'EARLIER',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...controller
                                .earlierNotifications()
                                .where((n) {
                                  if (controller.selectedType.value == 'all')
                                    return true;
                                  return n['data']['type'] ==
                                      controller.selectedType.value;
                                })
                                .map((n) {
                                  final data = n['data'];
                                  return _notificationTile(n, data);
                                })
                                .toList(),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
