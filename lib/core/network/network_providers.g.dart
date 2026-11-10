// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The bundle the seed JSON is read from.

@ProviderFor(assetBundle)
final assetBundleProvider = AssetBundleProvider._();

/// The bundle the seed JSON is read from.

final class AssetBundleProvider
    extends $FunctionalProvider<AssetBundle, AssetBundle, AssetBundle>
    with $Provider<AssetBundle> {
  /// The bundle the seed JSON is read from.
  AssetBundleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetBundleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetBundleHash();

  @$internal
  @override
  $ProviderElement<AssetBundle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssetBundle create(Ref ref) {
    return assetBundle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetBundle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetBundle>(value),
    );
  }
}

String _$assetBundleHash() => r'05918ac73d48cecb019264aef4f8b20db4807660';

/// The simulated network: latency and failures. Tests override it with
/// `NetworkSimulator(latencyFactor: 0)` for instant replies.

@ProviderFor(networkSimulator)
final networkSimulatorProvider = NetworkSimulatorProvider._();

/// The simulated network: latency and failures. Tests override it with
/// `NetworkSimulator(latencyFactor: 0)` for instant replies.

final class NetworkSimulatorProvider
    extends
        $FunctionalProvider<
          NetworkSimulator,
          NetworkSimulator,
          NetworkSimulator
        >
    with $Provider<NetworkSimulator> {
  /// The simulated network: latency and failures. Tests override it with
  /// `NetworkSimulator(latencyFactor: 0)` for instant replies.
  NetworkSimulatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkSimulatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkSimulatorHash();

  @$internal
  @override
  $ProviderElement<NetworkSimulator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetworkSimulator create(Ref ref) {
    return networkSimulator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkSimulator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkSimulator>(value),
    );
  }
}

String _$networkSimulatorHash() => r'9f19bae22a107d200dc1210460e63858a8711dea';

@ProviderFor(fakeServer)
final fakeServerProvider = FakeServerProvider._();

final class FakeServerProvider
    extends $FunctionalProvider<FakeServer, FakeServer, FakeServer>
    with $Provider<FakeServer> {
  FakeServerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fakeServerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fakeServerHash();

  @$internal
  @override
  $ProviderElement<FakeServer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FakeServer create(Ref ref) {
    return fakeServer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FakeServer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FakeServer>(value),
    );
  }
}

String _$fakeServerHash() => r'1d698d3d2e544d2c7c01efb24c1564d7f19cb0b1';

@ProviderFor(fakeApiClient)
final fakeApiClientProvider = FakeApiClientProvider._();

final class FakeApiClientProvider
    extends $FunctionalProvider<FakeApiClient, FakeApiClient, FakeApiClient>
    with $Provider<FakeApiClient> {
  FakeApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fakeApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fakeApiClientHash();

  @$internal
  @override
  $ProviderElement<FakeApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FakeApiClient create(Ref ref) {
    return fakeApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FakeApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FakeApiClient>(value),
    );
  }
}

String _$fakeApiClientHash() => r'16f2a969f9774e65ab43eb00b8da6e0c1d3a1d17';

/// Typed as the interface: what a repository depends on.

@ProviderFor(feedApiService)
final feedApiServiceProvider = FeedApiServiceProvider._();

/// Typed as the interface: what a repository depends on.

final class FeedApiServiceProvider
    extends $FunctionalProvider<FeedApiService, FeedApiService, FeedApiService>
    with $Provider<FeedApiService> {
  /// Typed as the interface: what a repository depends on.
  FeedApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedApiServiceHash();

  @$internal
  @override
  $ProviderElement<FeedApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedApiService create(Ref ref) {
    return feedApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedApiService>(value),
    );
  }
}

String _$feedApiServiceHash() => r'601407c7caea6081d529ec2fd1682ff5b7d26af6';
