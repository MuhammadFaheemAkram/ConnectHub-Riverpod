import 'package:connect_hub_riverpod/domain/model/app_notification.dart';
import 'package:connect_hub_riverpod/domain/repository/notification_repository.dart';

/// The cached notifications, newest first, live.
class WatchNotificationsUseCase {
  const WatchNotificationsUseCase(this._notifications);

  final NotificationRepository _notifications;

  Stream<List<AppNotification>> call() => _notifications.watchNotifications();
}
