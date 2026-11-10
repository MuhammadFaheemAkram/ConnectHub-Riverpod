import 'package:connect_hub_riverpod/domain/model/app_settings.dart';
import 'package:connect_hub_riverpod/domain/model/app_theme_mode.dart';

/// The device's preferences. It hides the storage, so the presentation layer
/// never reads preferences directly.
abstract interface class SettingsRepository {
  /// The current settings, available synchronously: the app reads them for
  /// its very first frame, so a saved dark theme never flashes light.
  AppSettings get current;

  Future<void> setThemeMode(AppThemeMode mode);

  Future<void> setUseDynamicColor({required bool enabled});

  Future<void> setShowUnreadBadge({required bool enabled});
}
