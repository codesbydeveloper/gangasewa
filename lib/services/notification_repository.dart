import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_notification.dart';
import 'mock_data.dart';

class NotificationRepository extends StateNotifier<List<AppNotification>> {
  NotificationRepository() : super(List.from(MockData.notifications));

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }
}

final notificationRepositoryProvider =
    StateNotifierProvider<NotificationRepository, List<AppNotification>>((ref) {
  return NotificationRepository();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).where((n) => !n.isRead).length;
});
