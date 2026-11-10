import 'package:connect_hub_riverpod/core/common/clock_provider.dart';
import 'package:connect_hub_riverpod/core/common/session_providers.dart';
import 'package:connect_hub_riverpod/core/network/api/fake_comment_api_service.dart';
import 'package:connect_hub_riverpod/core/network/api/fake_feed_api_service.dart';
import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:connect_hub_riverpod/data/repository/comment_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/feed_repository_impl.dart';
import 'package:connect_hub_riverpod/data/repository/post_repository_impl.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/di/use_case_providers.dart';
import 'package:connect_hub_riverpod/features/feed/feed_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/backend.dart';
import '../helpers/fakes/fake_feed_repository.dart';
import '../helpers/fakes/gated_feed_api.dart';

// Providers are the DI. These tests are what ConnectHub-Flutter's "the get_it
// graph resolves" test was, plus what a service locator can't offer: an
// override replaces a dependency for everything built on it, in one
// container only.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the real graph builds: every dependency resolves', () {
    final container = testContainer();

    expect(container.read(feedRepositoryProvider), isA<FeedRepositoryImpl>());
    expect(container.read(postRepositoryProvider), isA<PostRepositoryImpl>());
    expect(
      container.read(commentRepositoryProvider),
      isA<CommentRepositoryImpl>(),
    );
    expect(container.read(feedApiServiceProvider), isA<FakeFeedApiService>());
    expect(
      container.read(commentApiServiceProvider),
      isA<FakeCommentApiService>(),
    );
    for (final provider in <ProviderListenable<Object>>[
      watchFeedUseCaseProvider,
      refreshFeedUseCaseProvider,
      loadMoreFeedUseCaseProvider,
      likePostUseCaseProvider,
      savePostUseCaseProvider,
      watchPostUseCaseProvider,
      refreshPostUseCaseProvider,
      createPostUseCaseProvider,
      watchCommentsUseCaseProvider,
      refreshCommentsUseCaseProvider,
      addCommentUseCaseProvider,
      deleteCommentUseCaseProvider,
      likeCommentUseCaseProvider,
      searchUseCaseProvider,
      watchSearchPeopleUseCaseProvider,
      watchSearchPostsUseCaseProvider,
      watchRecentSearchesUseCaseProvider,
      saveRecentSearchUseCaseProvider,
      clearRecentSearchesUseCaseProvider,
      watchNotificationsUseCaseProvider,
      watchUnreadNotificationCountUseCaseProvider,
      refreshNotificationsUseCaseProvider,
      markNotificationReadUseCaseProvider,
      markAllNotificationsReadUseCaseProvider,
      watchUserUseCaseProvider,
      refreshUserUseCaseProvider,
      watchUserPostsUseCaseProvider,
      refreshUserPostsUseCaseProvider,
      watchSavedPostsUseCaseProvider,
      refreshSavedPostsUseCaseProvider,
      clearCacheUseCaseProvider,
      getNetworkFailureUseCaseProvider,
      setNetworkFailureUseCaseProvider,
      getSettingsUseCaseProvider,
      updateSettingsUseCaseProvider,
    ]) {
      expect(() => container.read(provider), returnsNormally);
    }
  });

  test(
    'overriding the API service reaches the repository built on it',
    () async {
      final container = testContainer(
        overrides: [
          ...realStack(),
          feedApiServiceProvider.overrideWith(
            (ref) => GatedFeedApi(
              FakeFeedApiService(
                ref.watch(fakeApiClientProvider),
                ref.watch(fakeServerProvider),
              ),
            ),
          ),
        ],
      );

      await container.read(feedRepositoryProvider).refresh();

      final api = container.read(feedApiServiceProvider) as GatedFeedApi;
      expect(api.requests, ['feed:top']);
    },
  );

  test(
    'overriding a repository reaches the use cases and the screen',
    () async {
      final fake = FakeFeedRepository();
      addTearDown(fake.dispose);
      final container = testContainer(
        overrides: [
          ...realStack(),
          feedRepositoryProvider.overrideWithValue(fake),
        ],
      );

      await container.read(feedControllerProvider.future);

      expect(fake.refreshCalls, 1);
    },
  );

  test('the preferences have no default: main must provide them', () {
    final container = ProviderContainer.test();

    // Riverpod 3 wraps what a provider threw (a `ProviderException`); the
    // message says what to do.
    expect(
      () => container.read(preferencesStoreProvider),
      throwsA(
        predicate(
          (error) => '$error'.contains('must be overridden before runApp'),
        ),
      ),
    );
  });

  test("the client's signed-in user is the server's demo user", () async {
    final container = testContainer();

    expect(
      await container.read(fakeServerProvider).signedInUserId(),
      container.read(signedInUserIdProvider),
    );
  });

  test('a different signed-in user changes whose comments are mine', () async {
    final container = testContainer(
      overrides: [
        ...realStack(),
        signedInUserIdProvider.overrideWithValue('u_grace'),
      ],
    );
    await container.read(feedRepositoryProvider).refresh();
    final comments = container.read(commentRepositoryProvider);
    await comments.refreshComments('p1');

    final mine = [
      for (final comment in await comments.watchComments('p1').first)
        if (comment.isMine) comment.id,
    ];
    // c1 on p1 is Grace Hopper's.
    expect(mine, contains('c1'));
  });

  test('overrides belong to one container: another one is untouched', () {
    final fake = FakeFeedRepository();
    addTearDown(fake.dispose);
    final overridden = testContainer(
      overrides: [
        ...realStack(),
        feedRepositoryProvider.overrideWithValue(fake),
      ],
    );
    final real = testContainer();

    expect(overridden.read(feedRepositoryProvider), same(fake));
    expect(real.read(feedRepositoryProvider), isA<FeedRepositoryImpl>());
  });

  group('lifetimes', () {
    test('app-lifetime objects are kept alive; use cases are not', () async {
      final container = testContainer();
      final keptAlive = <ProviderListenable<Object>>[
        clockProvider,
        networkSimulatorProvider,
        fakeServerProvider,
        feedApiServiceProvider,
        appDatabaseProvider,
        feedRepositoryProvider,
        postRepositoryProvider,
        commentRepositoryProvider,
        searchRepositoryProvider,
        notificationRepositoryProvider,
        idGeneratorProvider,
        signedInUserIdProvider,
      ];
      for (final provider in keptAlive) {
        container.read(provider);
      }
      container.read(likePostUseCaseProvider);

      await pumpEventQueue();

      expect(container.read(fakeServerProvider.exists), isTrue);
      expect(container.read(appDatabaseProvider.exists), isTrue);
      expect(container.read(feedRepositoryProvider.exists), isTrue);
      expect(container.read(postRepositoryProvider.exists), isTrue);
      expect(container.read(commentRepositoryProvider.exists), isTrue);
      expect(container.read(searchRepositoryProvider.exists), isTrue);
      expect(container.read(notificationRepositoryProvider.exists), isTrue);
      expect(container.read(signedInUserIdProvider.exists), isTrue);
      expect(container.read(likePostUseCaseProvider.exists), isFalse);
    });

    test("the database is closed with its container (the app's own "
        'provider: tests swap only its connection)', () async {
      final container = ProviderContainer(overrides: realStack());
      final database = container.read(appDatabaseProvider);
      await database.feedDao.replaceFeed([]);

      container.dispose();
      await pumpEventQueue();

      await expectLater(database.feedDao.replaceFeed([]), throwsA(anything));
    });
  });
}
