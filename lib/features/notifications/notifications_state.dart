import 'package:connect_hub_riverpod/domain/model/app_notification.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_state.freezed.dart';

/// The chips above the list.
enum NotificationFilter {
  all('All'),
  unread('Unread');

  const NotificationFilter(this.label);

  final String label;
}

/// What the Notifications tab shows once it has loaded.
@freezed
abstract class NotificationsState with _$NotificationsState {
  const NotificationsState._();

  const factory NotificationsState({
    /// Every cached notification, newest first.
    required List<AppNotification> notifications,
    @Default(NotificationFilter.all) NotificationFilter filter,

    /// A one-off SnackBar, consumed by `messageShown()`.
    String? message,
  }) = _NotificationsState;

  /// What the list shows under the chosen filter.
  List<AppNotification> get visible => switch (filter) {
    NotificationFilter.all => notifications,
    NotificationFilter.unread => [
      for (final notification in notifications)
        if (!notification.isRead) notification,
    ],
  };

  /// "Mark all read" is enabled while this is true.
  bool get hasUnread =>
      notifications.any((notification) => !notification.isRead);
}
