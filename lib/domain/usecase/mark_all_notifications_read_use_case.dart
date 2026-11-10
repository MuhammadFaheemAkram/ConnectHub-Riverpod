import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/notification_repository.dart';

/// Marks every notification read (optimistic, rolled back on failure).
class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._notifications);

  final NotificationRepository _notifications;

  Future<Result<void>> call() => _notifications.markAllRead();
}
