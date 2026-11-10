// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's preferences, as state the whole app watches.
///
/// - **Synchronous:** `build` reads the stored settings at once (the store
///   was opened before `runApp`), so `MaterialApp` has the saved theme on
///   its very first frame: no light flash before dark (Rule 9).
/// - **`keepAlive`:** the app widget watches it for its whole life anyway;
///   saying so makes the intent explicit, and keeps it during a frame where
///   nothing happens to watch it.
/// - Each change applies at once (the state) and is persisted (the store).

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// The app's preferences, as state the whole app watches.
///
/// - **Synchronous:** `build` reads the stored settings at once (the store
///   was opened before `runApp`), so `MaterialApp` has the saved theme on
///   its very first frame: no light flash before dark (Rule 9).
/// - **`keepAlive`:** the app widget watches it for its whole life anyway;
///   saying so makes the intent explicit, and keeps it during a frame where
///   nothing happens to watch it.
/// - Each change applies at once (the state) and is persisted (the store).
final class SettingsControllerProvider
    extends $NotifierProvider<SettingsController, AppSettings> {
  /// The app's preferences, as state the whole app watches.
  ///
  /// - **Synchronous:** `build` reads the stored settings at once (the store
  ///   was opened before `runApp`), so `MaterialApp` has the saved theme on
  ///   its very first frame: no light flash before dark (Rule 9).
  /// - **`keepAlive`:** the app widget watches it for its whole life anyway;
  ///   saying so makes the intent explicit, and keeps it during a frame where
  ///   nothing happens to watch it.
  /// - Each change applies at once (the state) and is persisted (the store).
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$settingsControllerHash() =>
    r'7ad0dfb0a77cd273861f644898fe34373460288b';

/// The app's preferences, as state the whole app watches.
///
/// - **Synchronous:** `build` reads the stored settings at once (the store
///   was opened before `runApp`), so `MaterialApp` has the saved theme on
///   its very first frame: no light flash before dark (Rule 9).
/// - **`keepAlive`:** the app widget watches it for its whole life anyway;
///   saying so makes the intent explicit, and keeps it during a frame where
///   nothing happens to watch it.
/// - Each change applies at once (the state) and is persisted (the store).

abstract class _$SettingsController extends $Notifier<AppSettings> {
  AppSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppSettings, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSettings, AppSettings>,
              AppSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Settings' actions: Clear cache and the developer switch. Screen-scoped
/// (auto-dispose), unlike the preferences.

@ProviderFor(SettingsTools)
final settingsToolsProvider = SettingsToolsProvider._();

/// Settings' actions: Clear cache and the developer switch. Screen-scoped
/// (auto-dispose), unlike the preferences.
final class SettingsToolsProvider
    extends $NotifierProvider<SettingsTools, SettingsToolsState> {
  /// Settings' actions: Clear cache and the developer switch. Screen-scoped
  /// (auto-dispose), unlike the preferences.
  SettingsToolsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsToolsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsToolsHash();

  @$internal
  @override
  SettingsTools create() => SettingsTools();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsToolsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsToolsState>(value),
    );
  }
}

String _$settingsToolsHash() => r'48df7e614affd5faf8dc29cb91c02eeb3581cb9d';

/// Settings' actions: Clear cache and the developer switch. Screen-scoped
/// (auto-dispose), unlike the preferences.

abstract class _$SettingsTools extends $Notifier<SettingsToolsState> {
  SettingsToolsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SettingsToolsState, SettingsToolsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SettingsToolsState, SettingsToolsState>,
              SettingsToolsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
