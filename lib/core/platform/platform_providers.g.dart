// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'platform_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's colors, or `null` where it has none (only Android 12+
/// does). Settings shows "Use wallpaper colors" only when this has a value.
///
/// `keepAlive`: asked once; the wallpaper doesn't change under a running
/// app often enough to watch. A platform with no plugin (tests, iOS) answers
/// with an exception, which means "no colors" too.

@ProviderFor(platformColorSchemes)
final platformColorSchemesProvider = PlatformColorSchemesProvider._();

/// The platform's colors, or `null` where it has none (only Android 12+
/// does). Settings shows "Use wallpaper colors" only when this has a value.
///
/// `keepAlive`: asked once; the wallpaper doesn't change under a running
/// app often enough to watch. A platform with no plugin (tests, iOS) answers
/// with an exception, which means "no colors" too.

final class PlatformColorSchemesProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlatformColorSchemes?>,
          PlatformColorSchemes?,
          FutureOr<PlatformColorSchemes?>
        >
    with
        $FutureModifier<PlatformColorSchemes?>,
        $FutureProvider<PlatformColorSchemes?> {
  /// The platform's colors, or `null` where it has none (only Android 12+
  /// does). Settings shows "Use wallpaper colors" only when this has a value.
  ///
  /// `keepAlive`: asked once; the wallpaper doesn't change under a running
  /// app often enough to watch. A platform with no plugin (tests, iOS) answers
  /// with an exception, which means "no colors" too.
  PlatformColorSchemesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformColorSchemesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformColorSchemesHash();

  @$internal
  @override
  $FutureProviderElement<PlatformColorSchemes?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlatformColorSchemes?> create(Ref ref) {
    return platformColorSchemes(ref);
  }
}

String _$platformColorSchemesHash() =>
    r'5a82657ab8143fd9ce9aa4fcd835c4de1459384d';

/// "1.0.0 (1)": the version and build, for Settings → About.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// "1.0.0 (1)": the version and build, for Settings → About.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// "1.0.0 (1)": the version and build, for Settings → About.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'ff1eb5d2af994c051622516f93f238f401bb6abc';
