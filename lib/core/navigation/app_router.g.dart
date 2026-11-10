// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [GoRouter], as a provider.
///
/// - **Why a provider:** the router can read other providers (Phase 5's
///   redirect for my own profile reads the signed-in user's id), and tests
///   reach the same instance through the container instead of a global.
/// - **Why `keepAlive`:** generated providers are disposed as soon as nothing
///   listens to them. The router holds the navigation stack, so it must live
///   as long as the app does, even in a frame where no widget watches it.
/// - **Disposal:** `ref.onDispose` releases the router with its container,
///   so every test (its own `ProviderScope`) starts from a fresh one.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's [GoRouter], as a provider.
///
/// - **Why a provider:** the router can read other providers (Phase 5's
///   redirect for my own profile reads the signed-in user's id), and tests
///   reach the same instance through the container instead of a global.
/// - **Why `keepAlive`:** generated providers are disposed as soon as nothing
///   listens to them. The router holds the navigation stack, so it must live
///   as long as the app does, even in a frame where no widget watches it.
/// - **Disposal:** `ref.onDispose` releases the router with its container,
///   so every test (its own `ProviderScope`) starts from a fresh one.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter], as a provider.
  ///
  /// - **Why a provider:** the router can read other providers (Phase 5's
  ///   redirect for my own profile reads the signed-in user's id), and tests
  ///   reach the same instance through the container instead of a global.
  /// - **Why `keepAlive`:** generated providers are disposed as soon as nothing
  ///   listens to them. The router holds the navigation stack, so it must live
  ///   as long as the app does, even in a frame where no widget watches it.
  /// - **Disposal:** `ref.onDispose` releases the router with its container,
  ///   so every test (its own `ProviderScope`) starts from a fresh one.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'cb9c5b3306e2f3241e94cabc43f8f0e3435fe8d8';
