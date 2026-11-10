import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/model/app_notification.dart';
import 'package:connect_hub_riverpod/features/notifications/notifications_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_notification_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

// The Notifications tab and the tab badge, with the notification repository
// replaced by a fake.
void main() {
  late FakeNotificationRepository notifications;

  final n1 = sampleNotification('n1', postId: 'p1');
  final n2 = sampleNotification('n2', minutesAgo: 5, isRead: true);
  final n3 = sampleNotification(
    'n3',
    minutesAgo: 10,
    kind: NotificationKind.follow,
    userId: 'u_ada',
  );

  Future<void> pumpApp(
    WidgetTester tester, {
    List<AppNotification> cached = const [],
    String at = '/notifications',
    void Function()? before,
  }) async {
    notifications = FakeNotificationRepository(cached: cached);
    before?.call();
    addTearDown(notifications.dispose);
    await pumpConnectHub(
      tester,
      at: at,
      overrides: [
        ...realStack(),
        notificationRepositoryProvider.overrideWithValue(notifications),
      ],
    );
  }

  Finder badge(String count) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(count),
  );

  TextButton markAll(WidgetTester tester) => tester.widget<TextButton>(
    find.widgetWithText(TextButton, 'Mark all read'),
  );

  testWidgets('the list, newest first, and the badge counts the unread', (
    tester,
  ) async {
    await pumpApp(tester, cached: [n1, n2, n3]);

    expect(find.text('Notification n1'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Notification n1')).dy,
      lessThan(tester.getTopLeft(find.text('Notification n3')).dy),
    );
    expect(badge('2'), findsOneWidget);
    expect(markAll(tester).onPressed, isNotNull);
  });

  testWidgets('the badge shows from launch, before the tab is opened', (
    tester,
  ) async {
    await pumpApp(
      tester,
      at: '/feed',
      before: () => notifications.refreshed = [n1, n2, n3],
    );

    expect(badge('2'), findsOneWidget);
    expect(notifications.refreshCalls, 1);
  });

  testWidgets('Unread filters; with nothing unread it says so', (tester) async {
    await pumpApp(tester, cached: [n1, n2]);

    await tester.tapAndSettle(find.widgetWithText(FilterChip, 'Unread'));
    expect(find.text('Notification n2'), findsNothing);
    expect(find.text('Notification n1'), findsOneWidget);

    await tester.tapAndSettle(find.text('Mark all read'));
    expect(find.text('Nothing unread.'), findsOneWidget);
    // At zero the badge is hidden, not "0".
    expect(badge('1'), findsNothing);
    expect(badge('0'), findsNothing);
    expect(markAll(tester).onPressed, isNull);
  });

  testWidgets('no notifications at all', (tester) async {
    await pumpApp(tester);

    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('a failure: the reason and "Try again"', (tester) async {
    await pumpApp(
      tester,
      before: () => notifications.refreshResult = const Err(NetworkException()),
    );
    expect(find.text(const NetworkException().message), findsOneWidget);

    notifications
      ..refreshResult = const Ok(null)
      ..refreshed = [n1];
    await tester.tapAndSettle(find.text('Try again'));

    expect(find.text('Notification n1'), findsOneWidget);
  });

  testWidgets('tapping one marks it read and opens its post', (tester) async {
    await pumpApp(tester, cached: [n1, n2, n3]);

    await tester.tapAndSettle(find.text('Notification n1'));

    expect(notifications.markReadCalls, ['n1']);
    expect(appBarTitled('Post'), findsOneWidget);
  });

  testWidgets('a follow opens the profile', (tester) async {
    await pumpApp(tester, cached: [n3]);

    await tester.tapAndSettle(find.text('Notification n3'));

    expect(appBarTitled('Profile'), findsOneWidget);
  });

  testWidgets('a mark read that fails says so', (tester) async {
    await pumpApp(
      tester,
      cached: [n2, sampleNotification('n6', minutesAgo: 20)],
      before: () =>
          notifications.markReadResult = const Err(NetworkException()),
    );

    await tester.tap(find.text('Notification n6'));
    await tester.pump();

    expect(
      find.text(NotificationsController.markReadFailedMessage),
      findsOneWidget,
    );
  });
}
