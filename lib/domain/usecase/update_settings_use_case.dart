import 'package:connect_hub_riverpod/domain/model/app_theme_mode.dart';
import 'package:connect_hub_riverpod/domain/repository/settings_repository.dart';

/// Changes one setting and persists it.
class UpdateSettingsUseCase {
  const UpdateSettingsUseCase(this._settings);

  final SettingsRepository _settings;

  Future<void> themeMode(AppThemeMode mode) => _settings.setThemeMode(mode);

  Future<void> useDynamicColor({required bool enabled}) =>
      _settings.setUseDynamicColor(enabled: enabled);

  Future<void> showUnreadBadge({required bool enabled}) =>
      _settings.setShowUnreadBadge(enabled: enabled);
}
