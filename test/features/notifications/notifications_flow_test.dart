import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:connect_hub_riverpod/features/notifications/notifications_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/pump_app.dart';

// Notifications end to end, on the real provider graph. The seed has eight
// for the demo user; n1, n2 and n3 are unread, and n1 (Grace Hopper liked
// a post) links to post p16.
void main() {
  Finder tab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Finder badge(String count) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(count),
  );

  final n1 = find.textContaining('Grace Hopper liked your post');

  testWidgets('the badge counts the unread from launch', (tester) async {
    await pumpConnectHub(tester);

    expect(badge('3'), findsOneWidget);
  });

  testWidgets('opening one reads it, here and on the server, and opens its '
      'post', (tester) async {
    final container = await pumpConnectHub(tester);
    await tester.tapAndSettle(tab('Notifications'));

    await tester.tapAndSettle(n1);

    expect(appBarTitled('Post'), findsOneWidget);
    await tester.tapAndSettle(find.byType(BackButton));
    expect(badge('2'), findsOneWidget);
    final server = container.read(fakeServerProvider);
    expect((await server.getNotifications('u_demo')).first.isRead, isTrue);
  });

  testWidgets('Mark all read clears the badge', (tester) async {
    final container = await pumpConnectHub(tester, at: '/notifications');

    await tester.tapAndSettle(find.text('Mark all read'));

    expect(badge('3'), findsNothing);
    final server = container.read(fakeServerProvider);
    final all = await server.getNotifications('u_demo');
    expect(all.every((notification) => notification.isRead), isTrue);
  });

  testWidgets('offline, marking read is undone and the screen says why', (
    tester,
  ) async {
    final container = await pumpConnectHub(tester, at: '/notifications');
    container.read(networkSimulatorProvider).failRequests = true;

    await tester.tapAndSettle(find.text('Mark all read'));

    expect(badge('3'), findsOneWidget);
    expect(
      find.text(NotificationsController.markAllFailedMessage),
      findsOneWidget,
    );
  });
}
