import 'dart:async';

import 'package:connect_hub_riverpod/core/common/first_value.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/di/use_case_providers.dart';
import 'package:connect_hub_riverpod/domain/model/app_notification.dart';
import 'package:connect_hub_riverpod/features/notifications/notifications_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_controller.g.dart';

/// The cached notifications, live.
@riverpod
Stream<List<AppNotification>> cachedNotifications(Ref ref) =>
    ref.watch(watchNotificationsUseCaseProvider)();

/// How many notifications are unread: the tab badge. A drift `COUNT` query
/// of its own, so the badge rebuilds only when the number changes.
@riverpod
Stream<int> unreadNotificationCount(Ref ref) =>
    ref.watch(watchUnreadNotificationCountUseCaseProvider)();

/// Drives the Notifications tab: the list, the filter, marking read.
///
/// The tab shell listens to it from launch, so the badge is right before
/// the tab is ever opened: the first load runs then, and the controller
/// lives as long as the shell does (the shell's `ref.listen` is its
/// listener). Opened later, the tab finds everything loaded.
@riverpod
class NotificationsController extends _$NotificationsController {
  static const refreshFailedMessage =
      "Couldn't refresh. Showing saved notifications.";
  static const markReadFailedMessage =
      "Couldn't mark it read. Please try again.";
  static const markAllFailedMessage =
      "Couldn't mark them all read. Please try again.";

  @override
  Future<NotificationsState> build() async {
    ref.watch(cacheEpochProvider);
    ref.listen(cachedNotificationsProvider, (_, next) {
      if (next case AsyncData(value: final notifications)) {
        _update((state) => state.copyWith(notifications: notifications));
      }
    });

    final cached = await _readCache();
    if (cached.isNotEmpty) {
      unawaited(Future(refresh));
      return NotificationsState(notifications: cached);
    }
    switch (await ref.read(refreshNotificationsUseCaseProvider)()) {
      case Ok():
        return NotificationsState(notifications: await _readCache());
      case Err(:final exception):
        throw exception;
    }
  }

  /// Pull to refresh, and the refresh behind the cache.
  Future<void> refresh() async {
    if (!ref.mounted) return;
    final result = await ref.read(refreshNotificationsUseCaseProvider)();
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        final notifications = await _readCache();
        if (!ref.mounted) return;
        _update((state) => state.copyWith(notifications: notifications));
      case Err():
        _update((state) => state.copyWith(message: refreshFailedMessage));
    }
  }

  void filterChanged(NotificationFilter filter) =>
      _update((state) => state.copyWith(filter: filter));

  /// Marks [notification] read: at once in the cache (the row and the badge
  /// change), confirmed or rolled back by the repository.
  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    final result = await ref.read(markNotificationReadUseCaseProvider)(
      notification.id,
    );
    if (!ref.mounted) return;
    if (result is Err<void>) {
      _update((state) => state.copyWith(message: markReadFailedMessage));
    }
  }

  Future<void> markAllRead() async {
    final result = await ref.read(markAllNotificationsReadUseCaseProvider)();
    if (!ref.mounted) return;
    if (result is Err<void>) {
      _update((state) => state.copyWith(message: markAllFailedMessage));
    }
  }

  void messageShown() => _update((state) => state.copyWith(message: null));

  Future<List<AppNotification>> _readCache() =>
      ref.read(watchNotificationsUseCaseProvider)().firstValue;

  /// Changes the state, if it has a value, and not while rebuilding (after
  /// Clear cache): the emptied cache must not replace what's on screen with
  /// "nothing" before the reload.
  void _update(NotificationsState Function(NotificationsState state) change) {
    final current = state.value;
    if (current != null && !state.isLoading) state = AsyncData(change(current));
  }
}
