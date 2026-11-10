import 'package:clock/clock.dart';
import 'package:connect_hub_riverpod/core/database/app_database.dart';
import 'package:connect_hub_riverpod/core/network/api/fake_comment_api_service.dart';
import 'package:connect_hub_riverpod/core/network/api/fake_feed_api_service.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/repository/comment_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/feed_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/notification_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/post_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backend.dart';
import 'fakes/gated_comment_api.dart';
import 'fakes/gated_feed_api.dart';

/// The app's real data stack for repository tests, built by the app's own
/// providers: the fake server, its API services, the repositories and an
/// in-memory database. Only the latency (zero), the clocks and the APIs
/// (wrapped so requests can be held in flight) are swapped.
///
/// ConnectHub-Flutter built the same stack by hand, constructor by
/// constructor. Here the container builds it, so the test also proves the
/// graph is wired the way the app wires it.
///
/// Create it in `setUp` or a test: its container is disposed when the test
/// ends, and closes the database.
class DataStack {
  /// [clientClock] is the app's clock (the repositories'); the server always
  /// runs on [testNow].
  DataStack({Clock? clientClock})
    : container = testContainer(
        overrides: [
          ...realStack(clock: clientClock),
          fakeServerProvider.overrideWith((ref) => newFakeServer()),
          feedApiServiceProvider.overrideWith(
            (ref) => GatedFeedApi(
              FakeFeedApiService(
                ref.watch(fakeApiClientProvider),
                ref.watch(fakeServerProvider),
              ),
            ),
          ),
          commentApiServiceProvider.overrideWith(
            (ref) => GatedCommentApi(
              FakeCommentApiService(
                ref.watch(fakeApiClientProvider),
                ref.watch(fakeServerProvider),
              ),
            ),
          ),
        ],
      );

  final ProviderContainer container;

  FakeServer get server => container.read(fakeServerProvider);
  NetworkSimulator get network => container.read(networkSimulatorProvider);
  AppDatabase get database => container.read(appDatabaseProvider);
  GatedFeedApi get api =>
      container.read(feedApiServiceProvider) as GatedFeedApi;
  GatedCommentApi get commentApi =>
      container.read(commentApiServiceProvider) as GatedCommentApi;
  FeedRepository get feed => container.read(feedRepositoryProvider);
  PostRepository get posts => container.read(postRepositoryProvider);
  CommentRepository get comments => container.read(commentRepositoryProvider);
  SearchRepository get search => container.read(searchRepositoryProvider);
  NotificationRepository get notifications =>
      container.read(notificationRepositoryProvider);

  /// The ids in the cached feed window, in order.
  Future<List<String>> feedIds() async => [
    for (final post in await feed.watchFeed().first) post.id,
  ];
}
