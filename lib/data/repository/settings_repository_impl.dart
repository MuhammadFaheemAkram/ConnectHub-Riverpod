import 'package:connect_hub_riverpod/core/storage/preferences_store.dart';
import 'package:connect_hub_riverpod/domain/model/app_settings.dart';
import 'package:connect_hub_riverpod/domain/model/app_theme_mode.dart';
import 'package:connect_hub_riverpod/domain/repository/settings_repository.dart';

/// The settings, kept in memory and persisted through a [PreferencesStore].
///
/// Stored values are enum names and booleans; unknown or missing values fall
/// back to the defaults.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._store) : _current = _read(_store);

  /// The keys live here and nowhere else.
  static const themeModeKey = 'settings.themeMode';
  static const useDynamicColorKey = 'settings.useDynamicColor';
  static const showUnreadBadgeKey = 'settings.showUnreadBadge';

  /// The only keys the preferences cache loads and allows writing.
  static const allowList = {
    themeModeKey,
    useDynamicColorKey,
    showUnreadBadgeKey,
  };

  final PreferencesStore _store;
  AppSettings _current;

  @override
  AppSettings get current => _current;

  @override
  Future<void> setThemeMode(AppThemeMode mode) {
    _current = _current.copyWith(themeMode: mode);
    return _store.setString(themeModeKey, mode.name);
  }

  @override
  Future<void> setUseDynamicColor({required bool enabled}) {
    _current = _current.copyWith(useDynamicColor: enabled);
    return _store.setBool(useDynamicColorKey, value: enabled);
  }

  @override
  Future<void> setShowUnreadBadge({required bool enabled}) {
    _current = _current.copyWith(showUnreadBadge: enabled);
    return _store.setBool(showUnreadBadgeKey, value: enabled);
  }

  static AppSettings _read(PreferencesStore store) => AppSettings(
    themeMode:
        AppThemeMode.values.asNameMap()[store.getString(themeModeKey)] ??
        AppThemeMode.system,
    useDynamicColor: store.getBool(useDynamicColorKey) ?? false,
    showUnreadBadge: store.getBool(showUnreadBadgeKey) ?? true,
  );
}
