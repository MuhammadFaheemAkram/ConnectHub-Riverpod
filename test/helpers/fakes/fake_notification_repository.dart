import 'dart:async';

import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/model/app_notification.dart';
import 'package:connect_hub_riverpod/domain/repository/notification_repository.dart';

/// A scriptable [NotificationRepository]. Marking read changes the cached
/// list at once (like the real one's optimistic write) unless a result says
/// it failed.
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({List<AppNotification> cached = const []})
    : _notifications = cached;

  List<AppNotification> _notifications;
  final _changes = StreamController<void>.broadcast();

  /// What `refresh` answers; a success caches [refreshed] (if set).
  Result<void> refreshResult = const Ok(null);
  List<AppNotification>? refreshed;

  /// While set and not completed, `refresh` waits for it.
  Completer<void>? refreshGate;
  int refreshCalls = 0;

  Result<void> markReadResult = const Ok(null);
  Result<void> markAllResult = const Ok(null);
  final markReadCalls = <String>[];
  int markAllCalls = 0;

  @override
  Stream<List<AppNotification>> watchNotifications() =>
      _watch(() => _notifications);

  @override
  Stream<int> watchUnreadCount() =>
      _watch(() => _notifications.where((n) => !n.isRead).length);

  @override
  Future<Result<void>> refresh() async {
    refreshCalls++;
    await refreshGate?.future;
    if (refreshResult is Ok<void>) {
      if (refreshed case final list?) _write(list);
    }
    return refreshResult;
  }

  @override
  Future<Result<void>> markRead(String notificationId) async {
    markReadCalls.add(notificationId);
    if (markReadResult is Ok<void>) {
      _write([
        for (final n in _notifications)
          n.id == notificationId ? n.copyWith(isRead: true) : n,
      ]);
    }
    return markReadResult;
  }

  @override
  Future<Result<void>> markAllRead() async {
    markAllCalls++;
    if (markAllResult is Ok<void>) {
      _write([for (final n in _notifications) n.copyWith(isRead: true)]);
    }
    return markAllResult;
  }

  void _write(List<AppNotification> notifications) {
    _notifications = notifications;
    _changes.add(null);
  }

  Stream<T> _watch<T>(T Function() read) => Stream.multi((watcher) {
    final subscription = _changes.stream.listen((_) => watcher.add(read()));
    watcher
      ..onCancel = subscription.cancel
      ..add(read());
  });

  Future<void> dispose() => _changes.close();
}
