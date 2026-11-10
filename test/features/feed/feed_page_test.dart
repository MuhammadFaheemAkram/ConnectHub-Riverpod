import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/features/feed/feed_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_feed_repository.dart';
import '../../helpers/fakes/fake_post_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

// The Feed page in each state, with the repositories replaced by fakes
// through the app's own ProviderScope.
void main() {
  late FakeFeedRepository feed;
  late FakePostRepository posts;

  Future<void> pumpFeed(
    WidgetTester tester, {
    List<Post> cached = const [],
    void Function()? before,
    bool settle = true,
  }) async {
    feed = FakeFeedRepository(cached: cached)
      // One page unless a test says otherwise: a fake that always has "more"
      // but adds nothing would keep a short list loading forever.
      ..loadMoreResult = const Ok(false);
    posts = FakePostRepository();
    before?.call();
    addTearDown(feed.dispose);
    await pumpConnectHub(
      tester,
      overrides: [
        ...realStack(),
        feedRepositoryProvider.overrideWithValue(feed),
        postRepositoryProvider.overrideWithValue(posts),
      ],
      settle: settle,
    );
  }

  final p1 = samplePost('p1');
  final p2 = samplePost('p2');

  testWidgets('loading: a spinner until the first page arrives', (
    tester,
  ) async {
    await pumpFeed(
      tester,
      before: () => feed.gate = Completer<void>(),
      settle: false,
    );

    expect(find.text('Loading posts…'), findsOneWidget);

    feed
      ..refreshedWindow = [p1]
      ..gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Post p1'), findsOneWidget);
  });

  testWidgets('error: the reason and "Try again", which shows the spinner '
      'while it loads again', (tester) async {
    await pumpFeed(
      tester,
      before: () => feed.refreshResult = const Err(NetworkException()),
    );

    expect(find.text(const NetworkException().message), findsOneWidget);

    feed
      ..refreshResult = const Ok(true)
      ..refreshedWindow = [p1]
      ..gate = Completer<void>();
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.text('Loading posts…'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);

    feed.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Post p1'), findsOneWidget);
  });

  testWidgets('empty: "No posts yet", and New post says it is coming', (
    tester,
  ) async {
    await pumpFeed(tester, before: () => feed.refreshedWindow = []);

    expect(find.text('No posts yet'), findsOneWidget);

    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'New post'));
    expect(find.text('Creating posts arrives in Phase 3.'), findsOneWidget);
  });

  testWidgets('loaded: the posts, newest first, then the footer', (
    tester,
  ) async {
    await pumpFeed(tester, cached: [p1, p2]);

    expect(find.text('Post p1'), findsOneWidget);
    expect(find.text('Post p2'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Post p1')).dy,
      lessThan(tester.getTopLeft(find.text('Post p2')).dy),
    );
    expect(find.text("You're all caught up"), findsOneWidget);
  });

  testWidgets("a page that failed: \"Couldn't load more\" and Retry", (
    tester,
  ) async {
    await pumpFeed(
      tester,
      cached: [p1],
      before: () => feed.loadMoreResult = const Err(NetworkException()),
    );

    expect(find.text("Couldn't load more"), findsOneWidget);
    expect(feed.loadMoreCalls, 1);

    feed
      ..loadMoreResult = const Ok(false)
      ..nextPage = [p2];
    await tester.tapAndSettle(find.text('Retry'));

    expect(feed.loadMoreCalls, 2);
    expect(find.text('Post p2'), findsOneWidget);
    expect(find.text("You're all caught up"), findsOneWidget);
  });

  testWidgets('a short feed keeps loading pages until the screen is full or '
      'the feed ends', (tester) async {
    await pumpFeed(tester, cached: [p1], before: () => feed.nextPage = [p2]);

    expect(feed.loadMoreCalls, 1);
    expect(find.text('Post p2'), findsOneWidget);
    expect(find.text("You're all caught up"), findsOneWidget);
  });

  testWidgets('like and save reach the repository', (tester) async {
    await pumpFeed(tester, cached: [p1]);

    await tester.tapAndSettle(find.byTooltip('Like'));
    await tester.tapAndSettle(find.byTooltip('Save'));

    expect(posts.likeCalls, [(postId: 'p1', liked: true)]);
    expect(posts.bookmarkCalls, [(postId: 'p1', bookmarked: true)]);
  });

  testWidgets('a failed like shows a SnackBar once, however often the feed '
      'rebuilds', (tester) async {
    await pumpFeed(tester, cached: [p1]);
    posts.likeResult = const Err(NetworkException());

    await tester.tap(find.byTooltip('Like'));
    await tester.pump();
    expect(find.text(FeedController.likeFailedMessage), findsOneWidget);

    // Let it go (its timer starts once it is fully in), then rebuild the
    // feed: the message was consumed, so nothing shows again.
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text(FeedController.likeFailedMessage), findsNothing);
    feed.replaceWindow([p1.copyWith(likeCount: 11)]);
    await tester.pumpAndSettle();
    expect(find.text(FeedController.likeFailedMessage), findsNothing);

    // The same failure again is a new message, and shows again.
    await tester.tap(find.byTooltip('Like'));
    await tester.pump();
    expect(find.text(FeedController.likeFailedMessage), findsOneWidget);
  });

  testWidgets('a failed pull to refresh keeps the posts and says why', (
    tester,
  ) async {
    await pumpFeed(tester, cached: [p1]);
    feed.refreshResult = const Err(NetworkException());

    await tester.fling(find.text('Post p1'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Post p1'), findsOneWidget);
    expect(find.text(FeedController.refreshFailedMessage), findsOneWidget);
  });
}
