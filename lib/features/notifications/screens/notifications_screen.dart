import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/app_notification.dart';
import '../../../services/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _icon(NotificationCategory c) => switch (c) {
        NotificationCategory.booking => Icons.event_available_outlined,
        NotificationCategory.payment => Icons.payments_outlined,
        NotificationCategory.video => Icons.videocam_outlined,
        NotificationCategory.system => Icons.info_outline,
      };

  Color _color(NotificationCategory c) => switch (c) {
        NotificationCategory.booking => AppColors.primary,
        NotificationCategory.payment => AppColors.success,
        NotificationCategory.video => AppColors.statusUpcoming,
        NotificationCategory.system => AppColors.info,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationRepositoryProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              message: 'Updates about bookings, payments and videos will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = items[i];
                return Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Mark read', style: TextStyle(color: AppColors.success)),
                  ),
                  onDismissed: (_) =>
                      ref.read(notificationRepositoryProvider.notifier).markRead(n.id),
                  child: Material(
                    color: n.isRead ? AppColors.white : AppColors.softBeige,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () =>
                          ref.read(notificationRepositoryProvider.notifier).markRead(n.id),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _color(n.category).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_icon(n.category), color: _color(n.category), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight:
                                                    n.isRead ? FontWeight.w600 : FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                      if (!n.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(n.body, style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 6),
                                  Text(
                                    Formatters.dateTime(n.createdAt),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
