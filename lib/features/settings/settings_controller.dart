import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/di/use_case_providers.dart';
import 'package:connect_hub_riverpod/domain/model/app_settings.dart';
import 'package:connect_hub_riverpod/domain/model/app_theme_mode.dart';
import 'package:connect_hub_riverpod/features/settings/settings_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

/// The app's preferences, as state the whole app watches.
///
/// - **Synchronous:** `build` reads the stored settings at once (the store
///   was opened before `runApp`), so `MaterialApp` has the saved theme on
///   its very first frame: no light flash before dark (Rule 9).
/// - **`keepAlive`:** the app widget watches it for its whole life anyway;
///   saying so makes the intent explicit, and keeps it during a frame where
///   nothing happens to watch it.
/// - Each change applies at once (the state) and is persisted (the store).
@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  @override
  AppSettings build() => ref.read(getSettingsUseCaseProvider)();

  Future<void> setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    return ref.read(updateSettingsUseCaseProvider).themeMode(mode);
  }

  Future<void> setUseDynamicColor({required bool enabled}) {
    state = state.copyWith(useDynamicColor: enabled);
    return ref
        .read(updateSettingsUseCaseProvider)
        .useDynamicColor(enabled: enabled);
  }

  Future<void> setShowUnreadBadge({required bool enabled}) {
    state = state.copyWith(showUnreadBadge: enabled);
    return ref
        .read(updateSettingsUseCaseProvider)
        .showUnreadBadge(enabled: enabled);
  }
}

/// Settings' actions: Clear cache and the developer switch. Screen-scoped
/// (auto-dispose), unlike the preferences.
@riverpod
class SettingsTools extends _$SettingsTools {
  static const clearedMessage =
      'Cache cleared. Posts and notifications download again.';

  @override
  SettingsToolsState build() => SettingsToolsState(
    failsRequests: ref.read(getNetworkFailureUseCaseProvider)(),
  );

  /// In memory only: it resets when the app restarts.
  void setNetworkFailure({required bool fail}) {
    ref.read(setNetworkFailureUseCaseProvider)(fail: fail);
    state = state.copyWith(failsRequests: fail);
  }

  /// Clears the cache, then bumps the cache's epoch: every screen showing
  /// server data watches it, rebuilds, and loads again.
  Future<void> clearCache() async {
    if (state.isClearingCache) return;
    state = state.copyWith(isClearingCache: true);
    // Read before the await: if Settings closes meanwhile, this notifier's
    // `ref` is gone, but the app-wide epoch must still be bumped.
    final epoch = ref.read(cacheEpochProvider.notifier);
    await ref.read(clearCacheUseCaseProvider)();
    epoch.cleared();
    if (!ref.mounted) return;
    state = state.copyWith(isClearingCache: false, message: clearedMessage);
  }

  void messageShown() => state = state.copyWith(message: null);
}
