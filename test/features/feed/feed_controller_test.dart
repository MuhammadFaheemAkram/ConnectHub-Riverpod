import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/features/feed/feed_controller.dart';
import 'package:connect_hub_riverpod/features/feed/feed_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_feed_repository.dart';
import '../../helpers/fakes/fake_post_repository.dart';
import '../../helpers/fixtures.dart';

// FeedController without widgets: a container whose repositories are fakes
// (`overrides`), and every state the controller emits, recorded in order.
// ConnectHub-Flutter tested its FeedCubit the same way with `bloc_test`;
// here the container plays `build:` and `container.listen` plays `expect:`.
void main() {
  late FakeFeedRepository feed;
  late FakePostRepository posts;
  late ProviderContainer container;

  /// Every state, from the first: `loading`, `error`, or `data` with the
  /// post ids, the footer and the message.
  late List<String> states;

  final p1 = samplePost('p1');
  final p2 = samplePost('p2');
  final p3 = samplePost('p3');

  String describe(AsyncValue<FeedState> value) => switch (value) {
    AsyncData(value: final feed) => [
      'data ${feed.posts.map((post) => post.id).join(',')}',
      if (feed.loadMore != LoadMoreStatus.idle) feed.loadMore.name,
      if (feed.message case final message?) '"$message"',
    ].join(' '),
    // Checked before the error, as the page does: reloading after a
    // failure is an `AsyncError` with `isLoading` set.
    AsyncValue(isLoading: true) => 'loading',
    AsyncError(:final error) => 'error ${error.runtimeType}',
    _ => 'loading',
  };

  /// Starts the controller (the first listener creates it) and records its
  /// states.
  void start({List<Post> cached = const []}) {
    feed = FakeFeedRepository(cached: cached);
    container = testContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(feed),
        postRepositoryProvider.overrideWithValue(posts),
      ],
    );
    states = [];
    container.listen(
      feedControllerProvider,
      (_, next) => states.add(describe(next)),
      fireImmediately: true,
    );
  }

  FeedController controller() =>
      container.read(feedControllerProvider.notifier);

  setUp(() => posts = FakePostRepository());

  tearDown(() => feed.dispose());

  group('first load', () {
    test('cached posts show at once; the refresh behind them updates '
        'them', () async {
      start(cached: [p1, p2]);
      feed.refreshedWindow = [p3, p1, p2];

      await pumpEventQueue();

      expect(states, ['loading', 'data p1,p2', 'data p3,p1,p2']);
      expect(feed.refreshCalls, 1);
    });

    test('regression: with posts cached, a refresh failure is reported '
        'however fast it fails', () async {
      // The refresh behind the cache starts on the next turn of the event
      // loop, once the cached state is in place. Started at once, a failure
      // that came back synchronously would find no state to put its message
      // in, and be lost.
      feed = FakeFeedRepository(cached: [p1])
        ..answerSynchronously = true
        ..refreshResult = const Err(NetworkException());
      container = testContainer(
        overrides: [
          feedRepositoryProvider.overrideWithValue(feed),
          postRepositoryProvider.overrideWithValue(posts),
        ],
      );
      states = [];
      container.listen(
        feedControllerProvider,
        (_, next) => states.add(describe(next)),
        fireImmediately: true,
      );

      await pumpEventQueue();

      expect(states.last, 'data p1 "${FeedController.refreshFailedMessage}"');
    });

    test('nothing cached: loading until the server answers', () async {
      start();
      feed
        ..gate = Completer<void>()
        ..refreshedWindow = [p1, p2];

      await pumpEventQueue();
      expect(states, ['loading']);

      feed.gate!.complete();
      await pumpEventQueue();
      expect(states, ['loading', 'data p1,p2']);
    });

    test('never shows an empty feed while the first page is on its way '
        '(drift announces it late)', () async {
      start();
      feed.refreshedWindow = [p1];

      await pumpEventQueue();

      expect(states, ['loading', 'data p1']);
    });

    test('the server has no posts: an empty feed', () async {
      start();
      feed.refreshedWindow = [];

      await pumpEventQueue();

      expect(states, ['loading', 'data ']);
    });

    test('the last page in one: the footer says the feed is done', () async {
      start();
      feed
        ..refreshedWindow = [p1]
        ..refreshResult = const Ok(false);

      await pumpEventQueue();

      expect(states.last, 'data p1 done');
    });

    test('nothing cached and the server fails: an error, and nothing '
        'retries behind the user\'s back', () async {
      start();
      feed.refreshResult = const Err(NetworkException());

      await pumpEventQueue();
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(states, ['loading', 'error NetworkException']);
      expect(feed.refreshCalls, 1);
    });

    test('"Try again" (invalidate) runs the first load again: loading, '
        'then the posts', () async {
      start();
      feed.refreshResult = const Err(NetworkException());
      await pumpEventQueue();

      feed
        ..refreshResult = const Ok(true)
        ..refreshedWindow = [p1];
      container.invalidate(feedControllerProvider);
      await pumpEventQueue();

      expect(states, [
        'loading',
        'error NetworkException',
        'loading',
        'data p1',
      ]);
      expect(feed.refreshCalls, 2);
    });
  });

  group('live posts', () {
    test('a change to the cache (a like anywhere) updates the posts in '
        'place, without loading again', () async {
      start(cached: [p1, p2]);
      await pumpEventQueue();

      feed.replaceWindow([p1.copyWith(isLiked: true, likeCount: 11), p2]);
      await pumpEventQueue();

      final current = container.read(feedControllerProvider).value!;
      expect(current.posts.first.isLiked, isTrue);
      expect(feed.refreshCalls, 1);
    });
  });

  group('pull to refresh', () {
    test('replaces the window', () async {
      start(cached: [p1]);
      await pumpEventQueue();
      feed.refreshedWindow = [p3, p2];

      await controller().refresh();
      await pumpEventQueue();

      expect(states.last, 'data p3,p2');
    });

    test('a failure keeps the posts and says so, once', () async {
      start(cached: [p1]);
      await pumpEventQueue();
      feed.refreshResult = const Err(NetworkException());

      await controller().refresh();
      expect(states.last, 'data p1 "${FeedController.refreshFailedMessage}"');

      controller().messageShown();
      expect(states.last, 'data p1');
    });

    test('the same failure again is shown again (the message was '
        'consumed)', () async {
      start(cached: [p1]);
      await pumpEventQueue();
      feed.refreshResult = const Err(NetworkException());

      await controller().refresh();
      controller().messageShown();
      await controller().refresh();

      final withMessage = states.where((state) => state.contains('"'));
      expect(withMessage, hasLength(2));
    });

    test('a failure with nothing to keep shows the error', () async {
      start();
      feed.refreshedWindow = [];
      await pumpEventQueue();
      feed.refreshResult = const Err(NetworkException());

      await controller().refresh();

      expect(states.last, 'error NetworkException');
    });
  });

  group('load more', () {
    Future<void> loaded() async {
      start(cached: [p1]);
      await pumpEventQueue();
      feed.nextPage = [p2];
    }

    test('idle → loading → idle, with the page appended', () async {
      await loaded();

      await controller().loadMore();
      await pumpEventQueue();

      expect(states.sublist(2), ['data p1 loading', 'data p1', 'data p1,p2']);
    });

    test('the last page: done, and further calls are ignored', () async {
      await loaded();
      feed.loadMoreResult = const Ok(false);

      await controller().loadMore();
      await controller().loadMore();
      await pumpEventQueue();

      expect(states.last, 'data p1,p2 done');
      expect(feed.loadMoreCalls, 1);
    });

    test('a failure shows in the footer; Retry tries again', () async {
      await loaded();
      feed.loadMoreResult = const Err(NetworkException());

      await controller().loadMore();
      expect(states.last, 'data p1 failed');

      feed.loadMoreResult = const Ok(true);
      await controller().loadMore();
      await pumpEventQueue();
      expect(states.last, 'data p1,p2');
      expect(feed.loadMoreCalls, 2);
    });

    test('a call while a page is loading is ignored', () async {
      await loaded();
      feed.gate = Completer<void>();

      final first = controller().loadMore();
      await controller().loadMore();
      feed.gate!.complete();
      await first;

      expect(feed.loadMoreCalls, 1);
    });

    test('nothing happens before the feed has loaded', () async {
      start();
      feed.gate = Completer<void>();

      await controller().loadMore();

      expect(feed.loadMoreCalls, 0);
      feed.gate!.complete();
    });
  });

  group('likes and saves', () {
    test('toggle the post through the repository', () async {
      start(cached: [p1]);
      await pumpEventQueue();

      await controller().toggleLike(p1);
      await controller().toggleLike(p1.copyWith(isLiked: true));
      await controller().toggleSave(p1);

      expect(posts.likeCalls, [
        (postId: 'p1', liked: true),
        (postId: 'p1', liked: false),
      ]);
      expect(posts.bookmarkCalls, [(postId: 'p1', bookmarked: true)]);
    });

    test('a failed like or save says so (the repository rolled it '
        'back)', () async {
      start(cached: [p1]);
      await pumpEventQueue();
      posts
        ..likeResult = const Err(NetworkException())
        ..bookmarkResult = const Err(NetworkException());

      await controller().toggleLike(p1);
      expect(states.last, 'data p1 "${FeedController.likeFailedMessage}"');

      controller().messageShown();
      await controller().toggleSave(p1);
      expect(states.last, 'data p1 "${FeedController.saveFailedMessage}"');
    });
  });

  group('lifetime', () {
    test('auto-dispose: the controller and its drift stream go when the '
        'Feed does', () async {
      feed = FakeFeedRepository(cached: [p1]);
      container = testContainer(
        overrides: [
          feedRepositoryProvider.overrideWithValue(feed),
          postRepositoryProvider.overrideWithValue(posts),
        ],
      );
      final subscription = container.listen(feedControllerProvider, (_, _) {});
      await pumpEventQueue();
      expect(container.read(feedPostsProvider.exists), isTrue);

      subscription.close();
      await pumpEventQueue();

      expect(container.read(feedControllerProvider.exists), isFalse);
      expect(container.read(feedPostsProvider.exists), isFalse);
    });

    test('an answer that arrives after the Feed is gone touches nothing '
        '(ref.mounted)', () async {
      feed = FakeFeedRepository(cached: [p1]);
      container = testContainer(
        overrides: [
          feedRepositoryProvider.overrideWithValue(feed),
          postRepositoryProvider.overrideWithValue(posts),
        ],
      );
      final subscription = container.listen(feedControllerProvider, (_, _) {});
      await pumpEventQueue();
      posts
        ..likeGate = Completer<void>()
        ..likeResult = const Err(NetworkException());

      final liking = container
          .read(feedControllerProvider.notifier)
          .toggleLike(p1);
      subscription.close();
      await pumpEventQueue();
      posts.likeGate!.complete();

      // Without the `ref.mounted` check, setting the message on a disposed
      // notifier throws here.
      await expectLater(liking, completes);
    });

    test('a pull to refresh that answers after the Feed is gone touches '
        'nothing (ref.mounted)', () async {
      feed = FakeFeedRepository(cached: [p1]);
      container = testContainer(
        overrides: [
          feedRepositoryProvider.overrideWithValue(feed),
          postRepositoryProvider.overrideWithValue(posts),
        ],
      );
      final subscription = container.listen(feedControllerProvider, (_, _) {});
      await pumpEventQueue();
      feed
        ..gate = Completer<void>()
        ..refreshedWindow = [p2, p1];

      final refreshing = container
          .read(feedControllerProvider.notifier)
          .refresh();
      subscription.close();
      await pumpEventQueue();
      feed.gate!.complete();

      // Without the `ref.mounted` check after the request, reading the cache
      // through a disposed `ref` throws here.
      await expectLater(refreshing, completes);
    });
  });
}
