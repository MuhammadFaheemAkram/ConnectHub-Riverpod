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

/// Ids for the posts and comments the server creates. Tests override it
/// with a seeded `Random` for repeatable ids.

@ProviderFor(idGenerator)
final idGeneratorProvider = IdGeneratorProvider._();

/// Ids for the posts and comments the server creates. Tests override it
/// with a seeded `Random` for repeatable ids.

final class IdGeneratorProvider
    extends $FunctionalProvider<IdGenerator, IdGenerator, IdGenerator>
    with $Provider<IdGenerator> {
  /// Ids for the posts and comments the server creates. Tests override it
  /// with a seeded `Random` for repeatable ids.
  IdGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'idGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$idGeneratorHash();

  @$internal
  @override
  $ProviderElement<IdGenerator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IdGenerator create(Ref ref) {
    return idGenerator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdGenerator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdGenerator>(value),
    );
  }
}

String _$idGeneratorHash() => r'bb966cf7718d55db97c350a71fc16f6b9658db70';

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

String _$fakeServerHash() => r'244d6b6fb64be0074779bf1824467d5d632f5107';

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

@ProviderFor(commentApiService)
final commentApiServiceProvider = CommentApiServiceProvider._();

final class CommentApiServiceProvider
    extends
        $FunctionalProvider<
          CommentApiService,
          CommentApiService,
          CommentApiService
        >
    with $Provider<CommentApiService> {
  CommentApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commentApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commentApiServiceHash();

  @$internal
  @override
  $ProviderElement<CommentApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommentApiService create(Ref ref) {
    return commentApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentApiService>(value),
    );
  }
}

String _$commentApiServiceHash() => r'8f9f496a92b61d0335689d1ac576d8752c53a5e7';

@ProviderFor(searchApiService)
final searchApiServiceProvider = SearchApiServiceProvider._();

final class SearchApiServiceProvider
    extends
        $FunctionalProvider<
          SearchApiService,
          SearchApiService,
          SearchApiService
        >
    with $Provider<SearchApiService> {
  SearchApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchApiServiceHash();

  @$internal
  @override
  $ProviderElement<SearchApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchApiService create(Ref ref) {
    return searchApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchApiService>(value),
    );
  }
}

String _$searchApiServiceHash() => r'9306458b184563aec7f4519c442ed4b35407a631';

@ProviderFor(notificationApiService)
final notificationApiServiceProvider = NotificationApiServiceProvider._();

final class NotificationApiServiceProvider
    extends
        $FunctionalProvider<
          NotificationApiService,
          NotificationApiService,
          NotificationApiService
        >
    with $Provider<NotificationApiService> {
  NotificationApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationApiServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationApiService create(Ref ref) {
    return notificationApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationApiService>(value),
    );
  }
}

String _$notificationApiServiceHash() =>
    r'1ed03016f8bb60892d879892df361852e34660e0';

@ProviderFor(userApiService)
final userApiServiceProvider = UserApiServiceProvider._();

final class UserApiServiceProvider
    extends $FunctionalProvider<UserApiService, UserApiService, UserApiService>
    with $Provider<UserApiService> {
  UserApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userApiServiceHash();

  @$internal
  @override
  $ProviderElement<UserApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserApiService create(Ref ref) {
    return userApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserApiService>(value),
    );
  }
}

String _$userApiServiceHash() => r'a91ee95c9298fdf69ee5971a48f3a6dff445b001';

@ProviderFor(developerToolsService)
final developerToolsServiceProvider = DeveloperToolsServiceProvider._();

final class DeveloperToolsServiceProvider
    extends
        $FunctionalProvider<
          DeveloperToolsService,
          DeveloperToolsService,
          DeveloperToolsService
        >
    with $Provider<DeveloperToolsService> {
  DeveloperToolsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'developerToolsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$developerToolsServiceHash();

  @$internal
  @override
  $ProviderElement<DeveloperToolsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeveloperToolsService create(Ref ref) {
    return developerToolsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeveloperToolsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeveloperToolsService>(value),
    );
  }
}

String _$developerToolsServiceHash() =>
    r'16ebb10b6ad207089449e12ff2937b2d5a159186';
