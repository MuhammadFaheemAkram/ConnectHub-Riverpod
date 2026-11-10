import 'package:connect_hub_riverpod/domain/repository/notification_repository.dart';

/// How many notifications are unread: the tab badge, live.
class WatchUnreadNotificationCountUseCase {
  const WatchUnreadNotificationCountUseCase(this._notifications);

  final NotificationRepository _notifications;

  Stream<int> call() => _notifications.watchUnreadCount();
}
