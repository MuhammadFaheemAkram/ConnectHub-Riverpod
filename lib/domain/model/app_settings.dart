import 'package:connect_hub_riverpod/domain/model/app_theme_mode.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Every persisted preference as one immutable value. They belong to the
/// device: Clear cache keeps them.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppThemeMode.system) AppThemeMode themeMode,

    /// Colors from the wallpaper (Android 12+), when the platform has them.
    @Default(false) bool useDynamicColor,

    /// Whether the Notifications tab shows the unread count.
    @Default(true) bool showUnreadBadge,
  }) = _AppSettings;
}
