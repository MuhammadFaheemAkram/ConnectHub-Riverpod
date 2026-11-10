import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/model/app_notification.dart';
import 'package:connect_hub_riverpod/features/notifications/notifications_controller.dart';
import 'package:connect_hub_riverpod/features/notifications/notifications_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_notification_repository.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeNotificationRepository notifications;
  late ProviderContainer container;
  late List<String> states;

  final n1 = sampleNotification('n1', postId: 'p1');
  final n2 = sampleNotification('n2', minutesAgo: 5, isRead: true);
  final n3 = sampleNotification('n3', minutesAgo: 10, userId: 'u_ada');

  String describe(AsyncValue<NotificationsState> value) => switch (value) {
    AsyncData(value: final state) => [
      'data',
      state.visible.map((n) => '${n.id}${n.isRead ? '' : '*'}').join(','),
      if (state.filter != NotificationFilter.all) state.filter.name,
      if (state.message case final message?) '"$message"',
    ].join(' '),
    AsyncValue(isLoading: true) => 'loading',
    AsyncError(:final error) => 'error ${error.runtimeType}',
    _ => 'loading',
  };

  void start({List<AppNotification> cached = const []}) {
    notifications = FakeNotificationRepository(cached: cached);
    container = testContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(notifications),
      ],
    );
    states = [];
    container.listen(
      notificationsControllerProvider,
      (_, next) => states.add(describe(next)),
      fireImmediately: true,
    );
  }

  NotificationsController controller() =>
      container.read(notificationsControllerProvider.notifier);

  tearDown(() => notifications.dispose());

  test(
    'nothing cached: loading, then the server\'s list (* = unread)',
    () async {
      start();
      notifications
        ..refreshGate = Completer<void>()
        ..refreshed = [n1, n2, n3];

      await pumpEventQueue();
      expect(states, ['loading']);

      notifications.refreshGate!.complete();
      await pumpEventQueue();
      expect(states.last, 'data n1*,n2,n3*');
    },
  );

  test('cached: shown at once, then refreshed behind', () async {
    start(cached: [n2]);
    notifications.refreshed = [n1, n2];

    await pumpEventQueue();

    expect(states.sublist(1), ['data n2', 'data n1*,n2']);
  });

  test('a first load that fails is an error; nothing retries it', () async {
    start();
    notifications.refreshResult = const Err(NetworkException());

    await pumpEventQueue();

    expect(states.last, 'error NetworkException');
    expect(notifications.refreshCalls, 1);
  });

  test('a failed refresh keeps the list and says so', () async {
    start(cached: [n1]);
    notifications.refreshResult = const Err(NetworkException());

    await pumpEventQueue();

    expect(
      states.last,
      'data n1* "${NotificationsController.refreshFailedMessage}"',
    );
  });

  test('Unread shows only the unread ones; All, everything', () async {
    start(cached: [n1, n2, n3]);
    await pumpEventQueue();

    controller().filterChanged(NotificationFilter.unread);
    expect(states.last, 'data n1*,n3* unread');

    controller().filterChanged(NotificationFilter.all);
    expect(states.last, 'data n1*,n2,n3*');
  });

  test('marking one read updates the list; one already read sends '
      'nothing', () async {
    start(cached: [n1, n2]);
    await pumpEventQueue();

    await controller().markRead(n1);
    await controller().markRead(n2);
    await pumpEventQueue();

    expect(notifications.markReadCalls, ['n1']);
    expect(states.last, 'data n1,n2');
  });

  test('mark all read; and "anything unread?" follows', () async {
    start(cached: [n1, n3]);
    await pumpEventQueue();
    expect(
      container.read(notificationsControllerProvider).value!.hasUnread,
      isTrue,
    );

    await controller().markAllRead();
    await pumpEventQueue();

    expect(states.last, 'data n1,n3');
    expect(
      container.read(notificationsControllerProvider).value!.hasUnread,
      isFalse,
    );
  });

  test('failures say what failed (the repository rolled them back)', () async {
    start(cached: [n1]);
    await pumpEventQueue();
    notifications
      ..markReadResult = const Err(NetworkException())
      ..markAllResult = const Err(NetworkException());

    await controller().markRead(n1);
    expect(
      states.last,
      'data n1* "${NotificationsController.markReadFailedMessage}"',
    );

    controller().messageShown();
    await controller().markAllRead();
    expect(
      states.last,
      'data n1* "${NotificationsController.markAllFailedMessage}"',
    );
  });

  test('the badge is the unread count, live', () async {
    start(cached: [n1, n2, n3]);
    final counts = <int>[];
    container.listen(
      unreadNotificationCountProvider,
      (_, next) => counts.add(next.value ?? -1),
      fireImmediately: true,
    );
    await pumpEventQueue();

    await controller().markRead(n1);
    await pumpEventQueue();

    expect(counts.where((count) => count >= 0), [2, 1]);
  });
}
