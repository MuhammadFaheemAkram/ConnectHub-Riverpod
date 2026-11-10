import 'package:connect_hub_riverpod/core/common/clock_provider.dart';
import 'package:connect_hub_riverpod/core/network/api/fake_feed_api_service.dart';
import 'package:connect_hub_riverpod/core/network/network_providers.dart';
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
    expect(container.read(feedApiServiceProvider), isA<FakeFeedApiService>());
    for (final provider in <ProviderListenable<Object>>[
      watchFeedUseCaseProvider,
      refreshFeedUseCaseProvider,
      loadMoreFeedUseCaseProvider,
      likePostUseCaseProvider,
      savePostUseCaseProvider,
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
