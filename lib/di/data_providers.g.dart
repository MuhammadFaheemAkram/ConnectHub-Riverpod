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
