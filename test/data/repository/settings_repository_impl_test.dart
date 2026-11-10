import 'package:connect_hub_riverpod/core/storage/preferences_store.dart';
import 'package:connect_hub_riverpod/data/repository/settings_repository_impl.dart';
import 'package:connect_hub_riverpod/domain/model/app_settings.dart';
import 'package:connect_hub_riverpod/domain/model/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../helpers/fakes/memory_preferences_store.dart';

void main() {
  test('nothing stored: the defaults', () {
    expect(
      SettingsRepositoryImpl(MemoryPreferencesStore()).current,
      const AppSettings(),
    );
  });

  test('unknown stored values fall back to the defaults', () {
    final repository = SettingsRepositoryImpl(
      MemoryPreferencesStore({SettingsRepositoryImpl.themeModeKey: 'sepia'}),
    );

    expect(repository.current.themeMode, AppThemeMode.system);
  });

  test('each change applies at once and is stored', () async {
    final store = MemoryPreferencesStore();
    final repository = SettingsRepositoryImpl(store);

    await repository.setThemeMode(AppThemeMode.dark);
    await repository.setUseDynamicColor(enabled: true);
    await repository.setShowUnreadBadge(enabled: false);

    expect(
      repository.current,
      const AppSettings(
        themeMode: AppThemeMode.dark,
        useDynamicColor: true,
        showUnreadBadge: false,
      ),
    );
    expect(store.values, {
      SettingsRepositoryImpl.themeModeKey: 'dark',
      SettingsRepositoryImpl.useDynamicColorKey: true,
      SettingsRepositoryImpl.showUnreadBadgeKey: false,
    });
  });

  test('persisted through SharedPreferencesWithCache: a new launch reads '
      'them back', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    Future<SharedPreferencesStore> open() async => SharedPreferencesStore(
      await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: SettingsRepositoryImpl.allowList,
        ),
      ),
    );

    await SettingsRepositoryImpl(await open()).setThemeMode(AppThemeMode.dark);

    final nextLaunch = SettingsRepositoryImpl(await open());
    expect(nextLaunch.current.themeMode, AppThemeMode.dark);
  });
}
