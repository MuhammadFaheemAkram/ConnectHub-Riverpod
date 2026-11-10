import 'package:connect_hub_riverpod/core/common/clock_provider.dart';
import 'package:connect_hub_riverpod/core/common/session_providers.dart';
import 'package:connect_hub_riverpod/core/database/app_database.dart';
import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:connect_hub_riverpod/core/storage/preferences_store.dart';
import 'package:connect_hub_riverpod/data/repository/cache_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/comment_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/demo_tools_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/feed_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/notification_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/post_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/profile_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/saved_posts_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/search_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/settings_repository_impl.dart';
import 'package:connect_hub_riverpod/domain/repository/cache_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/comment_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/demo_tools_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/feed_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/notification_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/post_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/profile_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/saved_posts_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/settings_repository.dart';
import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_providers.g.dart';

// The data layer's object graph. In ConnectHub-Flutter, these were
// `@LazySingleton(as: …)` classes and an injectable module; here, each is a
// function that builds the object from the providers it watches. The graph is
// checked at compile time: a missing dependency is a missing provider, not a
// runtime "not registered" error.
//
// Everything here is `keepAlive`, because each object lives as long as the
// app: one database connection (several would break drift's change
// notifications), and repositories that hold state (the feed's cursor, the
// likes in flight).

/// Where the database lives: `connect_hub_riverpod.sqlite` in the app's
/// documents directory. Tests override this one provider with an in-memory
/// connection, so the real [appDatabase] provider (and its disposal) still
/// runs in every test.
@Riverpod(keepAlive: true)
QueryExecutor databaseConnection(Ref ref) =>
    driftDatabase(name: 'connect_hub_riverpod');

/// The one database, closed with its container (which closes its
/// connection too).
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase(ref.watch(databaseConnectionProvider));
  ref.onDispose(database.close);
  return database;
}

/// Typed as the domain's interface, so features depend on the contract and a
/// test can override it with a fake.
@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) => FeedRepositoryImpl(
  ref.watch(feedApiServiceProvider),
  ref.watch(appDatabaseProvider).feedDao,
);

@Riverpod(keepAlive: true)
PostRepository postRepository(Ref ref) => PostRepositoryImpl(
  ref.watch(feedApiServiceProvider),
  ref.watch(appDatabaseProvider).postsDao,
  ref.watch(appDatabaseProvider).feedDao,
  ref.watch(clockProvider),
);

/// A repository depending on another (it fetches a post that isn't cached
/// before caching its comments): one more `ref.watch`.
@Riverpod(keepAlive: true)
CommentRepository commentRepository(Ref ref) => CommentRepositoryImpl(
  ref.watch(commentApiServiceProvider),
  ref.watch(appDatabaseProvider).commentsDao,
  ref.watch(appDatabaseProvider).postsDao,
  ref.watch(postRepositoryProvider),
  signedInUserId: ref.watch(signedInUserIdProvider),
);

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) => SearchRepositoryImpl(
  ref.watch(searchApiServiceProvider),
  ref.watch(appDatabaseProvider).searchDao,
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepositoryImpl(
      ref.watch(notificationApiServiceProvider),
      ref.watch(appDatabaseProvider).notificationsDao,
    );

/// Where the settings are stored. There is no default: `main` creates
/// `SharedPreferencesWithCache` *before* `runApp` and overrides this
/// provider with it, so the settings are readable synchronously from the
/// very first frame (no theme flash, Rule 9). Tests override it with an
/// in-memory store.
@Riverpod(keepAlive: true)
PreferencesStore preferencesStore(Ref ref) => throw UnimplementedError(
  'preferencesStoreProvider must be overridden before runApp (see main.dart)',
);

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepositoryImpl(ref.watch(preferencesStoreProvider));

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
  ref.watch(userApiServiceProvider),
  ref.watch(appDatabaseProvider).usersDao,
  ref.watch(appDatabaseProvider).postsDao,
);

@Riverpod(keepAlive: true)
SavedPostsRepository savedPostsRepository(Ref ref) => SavedPostsRepositoryImpl(
  ref.watch(feedApiServiceProvider),
  ref.watch(appDatabaseProvider).bookmarksDao,
);

@Riverpod(keepAlive: true)
CacheRepository cacheRepository(Ref ref) => CacheRepositoryImpl(
  ref.watch(appDatabaseProvider).cacheDao,
  signedInUserId: ref.watch(signedInUserIdProvider),
);

@Riverpod(keepAlive: true)
DemoToolsRepository demoToolsRepository(Ref ref) =>
    DemoToolsRepositoryImpl(ref.watch(developerToolsServiceProvider));

/// Bumped by Clear cache. The screens that show the server's data *watch*
/// it, so clearing the cache rebuilds them, and they load again instead of
/// showing their emptied cache as "nothing here". ConnectHub-Flutter sent a
/// "cache cleared" stream that each Cubit subscribed to; here it's one
/// `ref.watch` per screen.
@Riverpod(keepAlive: true)
class CacheEpoch extends _$CacheEpoch {
  @override
  int build() => 0;

  void cleared() => state++;
}
