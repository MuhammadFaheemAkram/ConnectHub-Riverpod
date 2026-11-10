import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/notification_repository.dart';

/// Makes the cached notifications match the server's, read states included.
class RefreshNotificationsUseCase {
  const RefreshNotificationsUseCase(this._notifications);

  final NotificationRepository _notifications;

  Future<Result<void>> call() => _notifications.refresh();
}
