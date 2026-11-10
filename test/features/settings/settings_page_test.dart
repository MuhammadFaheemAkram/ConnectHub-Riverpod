import 'package:connect_hub_riverpod/app/connect_hub_app.dart';
import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/app_router.dart';
import 'package:connect_hub_riverpod/data/repository/settings_repository_impl.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/features/feed/feed_controller.dart';
import 'package:connect_hub_riverpod/features/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/backend.dart';
import '../../helpers/fakes/memory_preferences_store.dart';
import '../../helpers/pump_app.dart';

// Settings on the real stack, with the preferences in memory.
void main() {
  Brightness brightness(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).last)).brightness;

  Finder badge(String count) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(count),
  );

  // p1, Ada Lovelace's newest post.
  final p1 = find.textContaining('analytical engine scheduler');

  testWidgets('a saved dark theme is there on the very first frame: no '
      'flash of light', (tester) async {
    tester.usePhoneSurface();
    final store = MemoryPreferencesStore({
      SettingsRepositoryImpl.themeModeKey: 'dark',
    });

    // One `pumpWidget`, nothing settled: the first frame.
    await tester.pumpWidget(
      ProviderScope(
        retry: noAutomaticRetry,
        overrides: realStack(preferences: store),
        child: const ConnectHubApp(),
      ),
    );

    expect(brightness(tester), Brightness.dark);
    await tester.pumpAndSettle();
  });

  testWidgets('Appearance applies at once, everywhere, and is stored', (
    tester,
  ) async {
    final store = MemoryPreferencesStore();
    await pumpConnectHub(
      tester,
      at: '/settings',
      overrides: realStack(preferences: store),
    );

    await tester.tapAndSettle(find.text('Dark'));
    expect(brightness(tester), Brightness.dark);
    expect(store.values[SettingsRepositoryImpl.themeModeKey], 'dark');

    await tester.tapAndSettle(find.text('Light'));
    expect(brightness(tester), Brightness.light);
  });

  testWidgets('"Use wallpaper colors" is hidden where the platform has '
      'none', (tester) async {
    await pumpConnectHub(tester, at: '/settings');

    expect(find.text('Use wallpaper colors'), findsNothing);
  });

  testWidgets('with wallpaper colors: the switch shows, and turning it on '
      "uses them (the like stays the app's red)", (tester) async {
    final wallpaper = (
      light: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      dark: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
      ),
    );
    await pumpConnectHub(
      tester,
      at: '/settings',
      overrides: realStack(wallpaperColors: wallpaper),
    );
    final context = tester.element(find.byType(Scaffold).last);
    expect(
      Theme.of(context).colorScheme.primary,
      isNot(wallpaper.light.primary),
    );

    await tester.tapAndSettle(find.text('Use wallpaper colors'));

    final themed = tester.element(find.byType(Scaffold).last);
    expect(Theme.of(themed).colorScheme.primary, wallpaper.light.primary);
    expect(Theme.of(themed).extension<AppColors>(), same(AppColors.light));
  });

  testWidgets('"Show unread badge" off hides the count', (tester) async {
    final container = await pumpConnectHub(tester);
    expect(badge('3'), findsOneWidget);

    container.read(appRouterProvider).go('/settings');
    await tester.pumpAndSettle();
    await tester.tapAndSettle(find.text('Show unread badge'));
    await tester.tapAndSettle(find.byTooltip('Go to the feed'));

    expect(badge('3'), findsNothing);
  });

  testWidgets('Clear cache asks first, then the feed loads again and saved '
      'posts stay', (tester) async {
    final container = await pumpConnectHub(tester);
    await tester.tapAndSettle(
      find.descendant(
        of: find.ancestor(of: p1, matching: find.byType(Card)),
        matching: find.byTooltip('Save'),
      ),
    );
    await tester.tapAndSettle(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.tapAndSettle(find.byTooltip('Settings'));

    await tester.tapAndSettle(find.text('Clear cache'));
    expect(find.text('Clear cache?'), findsOneWidget);
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Clear'));

    expect(find.text(SettingsTools.clearedMessage), findsOneWidget);
    final feed = await container.read(feedControllerProvider.future);
    expect(feed.posts, hasLength(6));
    expect(feed.posts.first.isBookmarked, isTrue);
  });

  testWidgets('Clear cache, then Cancel: nothing is cleared', (tester) async {
    final container = await pumpConnectHub(tester, at: '/settings');

    await tester.tapAndSettle(find.text('Clear cache'));
    await tester.tapAndSettle(find.text('Cancel'));

    expect(find.text('Clear cache?'), findsNothing);
    expect(container.read(cacheEpochProvider), 0);
    expect(find.text(SettingsTools.clearedMessage), findsNothing);
  });

  testWidgets('"Simulate network failure" makes the feed fail to refresh', (
    tester,
  ) async {
    await pumpConnectHub(tester, at: '/settings');

    await tester.tapAndSettle(find.text('Simulate network failure'));
    // Opened by its link: Back goes to the feed.
    await tester.tapAndSettle(find.byTooltip('Go to the feed'));
    await tester.fling(p1, const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text(FeedController.refreshFailedMessage), findsOneWidget);
  });

  testWidgets('About shows the version', (tester) async {
    await pumpConnectHub(tester, at: '/settings');

    await tester.scrollUntilVisible(
      find.text('Version 1.0.0 (1)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Version 1.0.0 (1)'), findsOneWidget);
  });
}
