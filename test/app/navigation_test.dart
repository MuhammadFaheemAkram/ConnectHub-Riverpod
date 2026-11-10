import 'package:connect_hub_riverpod/core/navigation/app_router.dart';
import 'package:connect_hub_riverpod/core/navigation/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';
import '../helpers/pump_app.dart';

// The whole app, as `main` builds it: the ProviderScope, the router provider,
// the tab shell and its pages.
void main() {
  final onFeed = appBarTitled('ConnectHub');
  final onSearch = appBarTitled('Search');
  final onNotifications = appBarTitled('Notifications');
  final onProfile = appBarTitled('Profile');
  final onSettings = appBarTitled('Settings');

  Finder tab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('launches on the Feed, with four tabs', (tester) async {
    await pumpConnectHub(tester);

    expect(onFeed, findsOneWidget);
    expect(tester.selectedTab, 0);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    for (final label in ['Feed', 'Search', 'Notifications', 'Profile']) {
      expect(tab(label), findsOneWidget);
    }
  });

  testWidgets('the tab labels keep their size at large text', (tester) async {
    // Four labels share a phone's width: scaled to 200 %, "Notifications"
    // would break mid-word. Screen readers and a long press still read it.
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await pumpConnectHub(tester);

    final body = find.text('Your feed is on its way');
    expect(MediaQuery.textScalerOf(tester.element(body)).scale(10), 20);
    for (final label in ['Feed', 'Search', 'Notifications', 'Profile']) {
      final scaler = MediaQuery.textScalerOf(tester.element(tab(label)));
      expect(scaler.scale(10), 10, reason: label);
    }
  });

  testWidgets('each tab opens its page', (tester) async {
    await pumpConnectHub(tester);

    for (final (index, label, page) in [
      (1, 'Search', onSearch),
      (2, 'Notifications', onNotifications),
      (3, 'Profile', onProfile),
      (0, 'Feed', onFeed),
    ]) {
      await tester.tapAndSettle(tab(label));

      expect(page, findsOneWidget, reason: label);
      expect(tester.selectedTab, index, reason: label);
    }
  });

  testWidgets('the tabs follow the router: one location per tab', (
    tester,
  ) async {
    final container = await pumpConnectHub(tester);
    GoRouter router() => container.read(appRouterProvider);
    String location() => router().state.uri.toString();

    await tester.tapAndSettle(tab('Notifications'));
    expect(location(), const NotificationsRoute().location);

    await tester.tapAndSettle(tab('Profile'));
    expect(location(), const ProfileRoute().location);
  });

  testWidgets("Profile's gear opens Settings above the tabs; Back returns", (
    tester,
  ) async {
    await pumpConnectHub(tester, at: '/profile');

    await tester.tapAndSettle(find.byTooltip('Settings'));

    expect(onSettings, findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tapAndSettle(find.byType(BackButton));

    expect(onProfile, findsOneWidget);
    expect(tester.selectedTab, 3);
  });

  group('Deep links', () {
    for (final (location, page, index) in [
      ('/feed', onFeed, 0),
      ('/search', onSearch, 1),
      ('/notifications', onNotifications, 2),
      ('/profile', onProfile, 3),
    ]) {
      testWidgets('$location selects its tab', (tester) async {
        await pumpConnectHub(tester, at: location);

        expect(page, findsOneWidget);
        expect(tester.selectedTab, index);
      });
    }

    testWidgets('/settings opens Settings without the tab bar', (tester) async {
      await pumpConnectHub(tester, at: '/settings');

      expect(onSettings, findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('an unknown location shows "Page not found", with a way '
        'back to the feed', (tester) async {
      await pumpConnectHub(tester, at: '/nowhere');

      expect(find.text('Page not found'), findsOneWidget);
      expect(find.text('Nothing lives at "/nowhere".'), findsOneWidget);

      await tester.tapAndSettle(find.text('Go to the feed'));

      expect(onFeed, findsOneWidget);
    });
  });

  group('Theme', () {
    for (final brightness in Brightness.values) {
      testWidgets('follows the device: ${brightness.name}', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearAllTestValues);

        await pumpConnectHub(tester);

        final context = tester.element(find.byType(Scaffold).first);
        expect(Theme.of(context).brightness, brightness);
      });
    }
  });
}
