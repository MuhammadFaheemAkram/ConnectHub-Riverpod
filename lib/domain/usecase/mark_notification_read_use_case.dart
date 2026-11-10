import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/notification_repository.dart';

/// Marks one notification read (optimistic, rolled back on failure).
class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._notifications);

  final NotificationRepository _notifications;

  Future<Result<void>> call(String notificationId) =>
      _notifications.markRead(notificationId);
}
