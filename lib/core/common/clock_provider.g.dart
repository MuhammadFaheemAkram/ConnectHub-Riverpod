// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current time, as a provider, so tests can fix it
/// (`clockProvider.overrideWithValue(Clock.fixed(…))`).
///
/// `keepAlive`: it holds nothing, but what reads it (the fake server, the
/// repositories) lives for the app's lifetime, so it says so too instead of
/// being kept alive only because they happen to watch it.

@ProviderFor(clock)
final clockProvider = ClockProvider._();

/// The current time, as a provider, so tests can fix it
/// (`clockProvider.overrideWithValue(Clock.fixed(…))`).
///
/// `keepAlive`: it holds nothing, but what reads it (the fake server, the
/// repositories) lives for the app's lifetime, so it says so too instead of
/// being kept alive only because they happen to watch it.

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  /// The current time, as a provider, so tests can fix it
  /// (`clockProvider.overrideWithValue(Clock.fixed(…))`).
  ///
  /// `keepAlive`: it holds nothing, but what reads it (the fake server, the
  /// repositories) lives for the app's lifetime, so it says so too instead of
  /// being kept alive only because they happen to watch it.
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'30e71d378a201482bb785bc8babd9bfcb65538f7';
