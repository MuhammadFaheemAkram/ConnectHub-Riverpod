import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// Settings' actions: the developer switch and Clear cache.
@freezed
abstract class SettingsToolsState with _$SettingsToolsState {
  const factory SettingsToolsState({
    @Default(false) bool failsRequests,
    @Default(false) bool isClearingCache,

    /// A one-off SnackBar, consumed by `messageShown()`.
    String? message,
  }) = _SettingsToolsState;
}
