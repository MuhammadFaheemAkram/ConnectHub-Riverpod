import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:connect_hub_riverpod/data/repository/settings_repository_impl.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/model/app_settings.dart';
import 'package:connect_hub_riverpod/domain/model/app_theme_mode.dart';
import 'package:connect_hub_riverpod/features/feed/feed_controller.dart';
import 'package:connect_hub_riverpod/features/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/fakes/memory_preferences_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsController', () {
    test('starts from what is stored, synchronously', () {
      final container = testContainer(
        overrides: realStack(
          preferences: MemoryPreferencesStore({
            SettingsRepositoryImpl.themeModeKey: 'dark',
            SettingsRepositoryImpl.showUnreadBadgeKey: false,
          }),
        ),
      );

      // No `await`: the very first read already has the stored values.
      expect(
        container.read(settingsControllerProvider),
        const AppSettings(themeMode: AppThemeMode.dark, showUnreadBadge: false),
      );
    });

    test('each change applies at once and is stored', () async {
      final store = MemoryPreferencesStore();
      final container = testContainer(overrides: realStack(preferences: store));
      final settings = container.read(settingsControllerProvider.notifier);

      await settings.setThemeMode(AppThemeMode.light);
      await settings.setUseDynamicColor(enabled: true);
      await settings.setShowUnreadBadge(enabled: false);

      expect(
        container.read(settingsControllerProvider),
        const AppSettings(
          themeMode: AppThemeMode.light,
          useDynamicColor: true,
          showUnreadBadge: false,
        ),
      );
      expect(store.values[SettingsRepositoryImpl.themeModeKey], 'light');
    });

    test('kept alive: the settings outlive a moment when nothing watches '
        'them', () async {
      final container = testContainer();
      await container
          .read(settingsControllerProvider.notifier)
          .setThemeMode(AppThemeMode.dark);

      await pumpEventQueue();

      expect(container.read(settingsControllerProvider.exists), isTrue);
    });
  });

  group('SettingsTools', () {
    late ProviderContainer container;

    setUp(() {
      container = testContainer();
      container.listen(settingsToolsProvider, (_, _) {});
    });

    test('the network switch fails every request, in memory', () {
      container
          .read(settingsToolsProvider.notifier)
          .setNetworkFailure(fail: true);

      expect(container.read(settingsToolsProvider).failsRequests, isTrue);
      expect(container.read(networkSimulatorProvider).failRequests, isTrue);
    });

    test('Clear cache clears, bumps the epoch, and says so', () async {
      await container.read(feedRepositoryProvider).refresh();
      final epoch = container.read(cacheEpochProvider);

      await container.read(settingsToolsProvider.notifier).clearCache();

      expect(container.read(cacheEpochProvider), epoch + 1);
      expect(
        await container.read(feedRepositoryProvider).watchFeed().first,
        isEmpty,
      );
      expect(
        container.read(settingsToolsProvider).message,
        SettingsTools.clearedMessage,
      );
      expect(container.read(settingsToolsProvider).isClearingCache, isFalse);
    });

    test('Clear cache: the feed reloads without ever showing "nothing" '
        '(the emptied cache is ignored while it reloads)', () async {
      final feed = <String>[];
      container.listen(
        feedControllerProvider,
        (_, next) => feed.add(switch (next) {
          AsyncValue(isLoading: true) => 'loading',
          AsyncData(:final value) => '${value.posts.length} posts',
          _ => 'error',
        }),
      );
      await container.read(feedControllerProvider.future);
      await pumpEventQueue();
      feed.clear();

      await container.read(settingsToolsProvider.notifier).clearCache();
      await container.read(feedControllerProvider.future);
      await pumpEventQueue();

      expect(feed, isNot(contains('0 posts')));
      expect(feed.first, 'loading');
      expect(feed.last, '6 posts');
    });

    test('closing Settings mid-clear still bumps the epoch', () async {
      final page = ProviderContainer.test(overrides: realStack());
      final open = page.listen(settingsToolsProvider, (_, _) {});
      final clearing = page.read(settingsToolsProvider.notifier).clearCache();
      open.close();

      await clearing;

      expect(page.read(cacheEpochProvider), 1);
    });
  });
}
