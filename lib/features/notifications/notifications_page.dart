import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/app_routes.dart';
import 'package:connect_hub_riverpod/domain/model/app_notification.dart';
import 'package:connect_hub_riverpod/features/notifications/notifications_controller.dart';
import 'package:connect_hub_riverpod/features/notifications/notifications_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The Notifications tab: All / Unread, the list newest first, pull to
/// refresh and "Mark all read". Tapping a row marks it read and opens what
/// it links to.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      notificationsControllerProvider.select((state) => state.value?.message),
      (_, message) {
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        ref.read(notificationsControllerProvider.notifier).messageShown();
      },
    );

    final notifications = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    // `select`: the app bar's button follows "anything unread?", not every
    // change to the list.
    final hasUnread = ref.watch(
      notificationsControllerProvider.select(
        (state) => state.value?.hasUnread ?? false,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: hasUnread ? controller.markAllRead : null,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: switch (notifications) {
        AsyncValue(value: final state?) => Column(
          children: [
            _FilterChips(
              selected: state.filter,
              onSelected: controller.filterChanged,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: state.visible.isEmpty
                    ? _NoNotifications(filtered: state.notifications.isNotEmpty)
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.visible.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notification = state.visible[index];
                          return NotificationTile(
                            key: ValueKey(notification.id),
                            notification: notification,
                            onTap: () =>
                                _open(context, controller, notification),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
        AsyncValue(isLoading: true) => const LoadingView(
          message: 'Loading notifications…',
        ),
        AsyncError(:final error) => ErrorView(
          message: error is AppException
              ? error.message
              : const UnknownException().message,
          onRetry: () => ref.invalidate(notificationsControllerProvider),
        ),
        _ => const LoadingView(message: 'Loading notifications…'),
      },
    );
  }

  /// Marks the row read and opens its post or profile, if it links to one.
  /// The page opens at once; marking read finishes in the background.
  static void _open(
    BuildContext context,
    NotificationsController controller,
    AppNotification notification,
  ) {
    controller.markRead(notification).ignore();
    if (notification.postId case final postId?) {
      PostDetailRoute(postId: postId).push<void>(context);
    } else if (notification.userId case final userId?) {
      openProfile(context, userId);
    }
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.xSmall,
        ),
        child: Wrap(
          spacing: AppSpacing.xSmall,
          children: [
            for (final filter in NotificationFilter.values)
              FilterChip(
                label: Text(filter.label),
                selected: filter == selected,
                onSelected: (_) => onSelected(filter),
              ),
          ],
        ),
      ),
    );
  }
}

/// "No notifications yet", or "Nothing unread." for the Unread filter;
/// still pullable to refresh.
class _NoNotifications extends StatelessWidget {
  const _NoNotifications({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: filtered
                ? const EmptyStateView(
                    icon: Icons.done_all,
                    title: 'Nothing unread.',
                  )
                : const EmptyStateView(
                    icon: Icons.notifications_none,
                    title: 'No notifications yet',
                    message:
                        'Likes, comments, follows and mentions will show '
                        'up here.',
                  ),
          ),
        ],
      ),
    );
  }
}
