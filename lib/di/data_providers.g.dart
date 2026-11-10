// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the database lives: `connect_hub_riverpod.sqlite` in the app's
/// documents directory. Tests override this one provider with an in-memory
/// connection, so the real [appDatabase] provider (and its disposal) still
/// runs in every test.

@ProviderFor(databaseConnection)
final databaseConnectionProvider = DatabaseConnectionProvider._();

/// Where the database lives: `connect_hub_riverpod.sqlite` in the app's
/// documents directory. Tests override this one provider with an in-memory
/// connection, so the real [appDatabase] provider (and its disposal) still
/// runs in every test.

final class DatabaseConnectionProvider
    extends $FunctionalProvider<QueryExecutor, QueryExecutor, QueryExecutor>
    with $Provider<QueryExecutor> {
  /// Where the database lives: `connect_hub_riverpod.sqlite` in the app's
  /// documents directory. Tests override this one provider with an in-memory
  /// connection, so the real [appDatabase] provider (and its disposal) still
  /// runs in every test.
  DatabaseConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseConnectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseConnectionHash();

  @$internal
  @override
  $ProviderElement<QueryExecutor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QueryExecutor create(Ref ref) {
    return databaseConnection(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueryExecutor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueryExecutor>(value),
    );
  }
}

String _$databaseConnectionHash() =>
    r'eba2e557d78606ad0ac775bc673c1533df3e748f';

/// The one database, closed with its container (which closes its
/// connection too).

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The one database, closed with its container (which closes its
/// connection too).

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The one database, closed with its container (which closes its
  /// connection too).
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'a35bd0c5f3b91d2ae9991da5b5b5a9e43685121f';

/// Typed as the domain's interface, so features depend on the contract and a
/// test can override it with a fake.

@ProviderFor(feedRepository)
final feedRepositoryProvider = FeedRepositoryProvider._();

/// Typed as the domain's interface, so features depend on the contract and a
/// test can override it with a fake.

final class FeedRepositoryProvider
    extends $FunctionalProvider<FeedRepository, FeedRepository, FeedRepository>
    with $Provider<FeedRepository> {
  /// Typed as the domain's interface, so features depend on the contract and a
  /// test can override it with a fake.
  FeedRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedRepository create(Ref ref) {
    return feedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRepository>(value),
    );
  }
}

String _$feedRepositoryHash() => r'e12c73130e45c29978968ea7ffe102cbac55e823';

@ProviderFor(postRepository)
final postRepositoryProvider = PostRepositoryProvider._();

final class PostRepositoryProvider
    extends $FunctionalProvider<PostRepository, PostRepository, PostRepository>
    with $Provider<PostRepository> {
  PostRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postRepositoryHash();

  @$internal
  @override
  $ProviderElement<PostRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostRepository create(Ref ref) {
    return postRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostRepository>(value),
    );
  }
}

String _$postRepositoryHash() => r'404532e655dfc9f76259de75d5c0c59098b50dd6';

/// A repository depending on another (it fetches a post that isn't cached
/// before caching its comments): one more `ref.watch`.

@ProviderFor(commentRepository)
final commentRepositoryProvider = CommentRepositoryProvider._();

/// A repository depending on another (it fetches a post that isn't cached
/// before caching its comments): one more `ref.watch`.

final class CommentRepositoryProvider
    extends
        $FunctionalProvider<
          CommentRepository,
          CommentRepository,
          CommentRepository
        >
    with $Provider<CommentRepository> {
  /// A repository depending on another (it fetches a post that isn't cached
  /// before caching its comments): one more `ref.watch`.
  CommentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commentRepositoryHash();

  @$internal
  @override
  $ProviderElement<CommentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommentRepository create(Ref ref) {
    return commentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentRepository>(value),
    );
  }
}

String _$commentRepositoryHash() => r'378d19229865579a04e1123b0530ee13493bd4a2';

@ProviderFor(searchRepository)
final searchRepositoryProvider = SearchRepositoryProvider._();

final class SearchRepositoryProvider
    extends
        $FunctionalProvider<
          SearchRepository,
          SearchRepository,
          SearchRepository
        >
    with $Provider<SearchRepository> {
  SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'7402d003720e66278b7023961d8a287ce9ff3e5f';

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'c44622116979649b2bf426ba8042cf749f5867bb';

/// Where the settings are stored. There is no default: `main` creates
/// `SharedPreferencesWithCache` *before* `runApp` and overrides this
/// provider with it, so the settings are readable synchronously from the
/// very first frame (no theme flash, Rule 9). Tests override it with an
/// in-memory store.

@ProviderFor(preferencesStore)
final preferencesStoreProvider = PreferencesStoreProvider._();

/// Where the settings are stored. There is no default: `main` creates
/// `SharedPreferencesWithCache` *before* `runApp` and overrides this
/// provider with it, so the settings are readable synchronously from the
/// very first frame (no theme flash, Rule 9). Tests override it with an
/// in-memory store.

final class PreferencesStoreProvider
    extends
        $FunctionalProvider<
          PreferencesStore,
          PreferencesStore,
          PreferencesStore
        >
    with $Provider<PreferencesStore> {
  /// Where the settings are stored. There is no default: `main` creates
  /// `SharedPreferencesWithCache` *before* `runApp` and overrides this
  /// provider with it, so the settings are readable synchronously from the
  /// very first frame (no theme flash, Rule 9). Tests override it with an
  /// in-memory store.
  PreferencesStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesStoreHash();

  @$internal
  @override
  $ProviderElement<PreferencesStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PreferencesStore create(Ref ref) {
    return preferencesStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesStore>(value),
    );
  }
}

String _$preferencesStoreHash() => r'96d13ac62af7b75eabc22c394cc1ce937aff09b3';

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'a8f0790c226f4c006e1cb3f02c88452cadcb63d3';

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'bf0308cd9edcb435af61133ff6113e6da7b5939d';

@ProviderFor(savedPostsRepository)
final savedPostsRepositoryProvider = SavedPostsRepositoryProvider._();

final class SavedPostsRepositoryProvider
    extends
        $FunctionalProvider<
          SavedPostsRepository,
          SavedPostsRepository,
          SavedPostsRepository
        >
    with $Provider<SavedPostsRepository> {
  SavedPostsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedPostsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedPostsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedPostsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedPostsRepository create(Ref ref) {
    return savedPostsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedPostsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedPostsRepository>(value),
    );
  }
}

String _$savedPostsRepositoryHash() =>
    r'115abac860eead51c5e96970f03d06389d5c8e93';

@ProviderFor(cacheRepository)
final cacheRepositoryProvider = CacheRepositoryProvider._();

final class CacheRepositoryProvider
    extends
        $FunctionalProvider<CacheRepository, CacheRepository, CacheRepository>
    with $Provider<CacheRepository> {
  CacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<CacheRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheRepository create(Ref ref) {
    return cacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheRepository>(value),
    );
  }
}

String _$cacheRepositoryHash() => r'62f3bbe97819acaf9d320a016b694ecc6d877ce6';

@ProviderFor(demoToolsRepository)
final demoToolsRepositoryProvider = DemoToolsRepositoryProvider._();

final class DemoToolsRepositoryProvider
    extends
        $FunctionalProvider<
          DemoToolsRepository,
          DemoToolsRepository,
          DemoToolsRepository
        >
    with $Provider<DemoToolsRepository> {
  DemoToolsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoToolsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoToolsRepositoryHash();

  @$internal
  @override
  $ProviderElement<DemoToolsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DemoToolsRepository create(Ref ref) {
    return demoToolsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoToolsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoToolsRepository>(value),
    );
  }
}

String _$demoToolsRepositoryHash() =>
    r'464706bbf98884221e4715aed806e591aff5481d';

/// Bumped by Clear cache. The screens that show the server's data *watch*
/// it, so clearing the cache rebuilds them, and they load again instead of
/// showing their emptied cache as "nothing here". ConnectHub-Flutter sent a
/// "cache cleared" stream that each Cubit subscribed to; here it's one
/// `ref.watch` per screen.

@ProviderFor(CacheEpoch)
final cacheEpochProvider = CacheEpochProvider._();

/// Bumped by Clear cache. The screens that show the server's data *watch*
/// it, so clearing the cache rebuilds them, and they load again instead of
/// showing their emptied cache as "nothing here". ConnectHub-Flutter sent a
/// "cache cleared" stream that each Cubit subscribed to; here it's one
/// `ref.watch` per screen.
final class CacheEpochProvider extends $NotifierProvider<CacheEpoch, int> {
  /// Bumped by Clear cache. The screens that show the server's data *watch*
  /// it, so clearing the cache rebuilds them, and they load again instead of
  /// showing their emptied cache as "nothing here". ConnectHub-Flutter sent a
  /// "cache cleared" stream that each Cubit subscribed to; here it's one
  /// `ref.watch` per screen.
  CacheEpochProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheEpochProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheEpochHash();

  @$internal
  @override
  CacheEpoch create() => CacheEpoch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cacheEpochHash() => r'fd1c263ecfe966bb726116d02d3d89402c2f0ca8';

/// Bumped by Clear cache. The screens that show the server's data *watch*
/// it, so clearing the cache rebuilds them, and they load again instead of
/// showing their emptied cache as "nothing here". ConnectHub-Flutter sent a
/// "cache cleared" stream that each Cubit subscribed to; here it's one
/// `ref.watch` per screen.

abstract class _$CacheEpoch extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
