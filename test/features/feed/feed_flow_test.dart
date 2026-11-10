import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:connect_hub_riverpod/features/feed/feed_controller.dart';
import 'package:connect_hub_riverpod/features/feed/feed_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';
import '../../helpers/pump_app.dart';

// The Feed end to end, on the real provider graph: fake server, API services,
// drift (in memory), repositories, use cases and the controller. Only the
// latency (zero), the clock (fixed) and the database (in memory) are
// overridden.
void main() {
  // p1, the newest post in the seed: Ada Lovelace's, with 142 likes.
  final firstPost = find.textContaining('analytical engine scheduler');

  Finder onCard(Finder post, Finder target) => find.descendant(
    of: find.ancestor(of: post, matching: find.byType(Card)),
    matching: target,
  );

  Future<void> pullToRefresh(WidgetTester tester) async {
    await tester.fling(firstPost, const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
  }

  testWidgets('a first launch shows the newest posts from the fake server', (
    tester,
  ) async {
    await pumpConnectHub(tester);

    expect(firstPost, findsOneWidget);
    expect(onCard(firstPost, find.text('Ada Lovelace')), findsOneWidget);
    expect(onCard(firstPost, find.text('142')), findsOneWidget);
    // Seed times are rebased: p1 is 3h old (2h55m before the newest seed
    // record, which is five minutes old).
    expect(onCard(firstPost, find.text('3h')), findsOneWidget);
  });

  test('a first launch never passes through an empty feed', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final container = testContainer();
    final states = <String>[];
    container.listen(
      feedControllerProvider,
      (_, next) => states.add(switch (next) {
        AsyncData(value: final feed) => 'data ${feed.posts.length}',
        _ => 'loading',
      }),
      fireImmediately: true,
    );

    await container.read(feedControllerProvider.future);
    await pumpEventQueue();

    expect(states, ['loading', 'data 6']);
  });

  testWidgets('a like shows at once, and the server keeps it', (tester) async {
    final container = await pumpConnectHub(tester);

    await tester.tapAndSettle(onCard(firstPost, find.byTooltip('Like')));

    expect(onCard(firstPost, find.byTooltip('Unlike')), findsOneWidget);
    expect(onCard(firstPost, find.text('143')), findsOneWidget);
    final server = container.read(fakeServerProvider);
    final serverView = await server.getFeed('u_demo', limit: 1);
    expect(serverView.posts.single.isLiked, isTrue);
  });

  testWidgets('a like the server refuses is rolled back, and the feed says '
      'why', (tester) async {
    final container = await pumpConnectHub(tester);
    container.read(networkSimulatorProvider).failRequests = true;

    await tester.tap(onCard(firstPost, find.byTooltip('Like')));
    await tester.pumpAndSettle();

    expect(onCard(firstPost, find.byTooltip('Like')), findsOneWidget);
    expect(onCard(firstPost, find.text('142')), findsOneWidget);
    expect(find.text(FeedController.likeFailedMessage), findsOneWidget);
  });

  testWidgets('a save shows at once, and the server keeps it', (tester) async {
    final container = await pumpConnectHub(tester);

    await tester.tapAndSettle(onCard(firstPost, find.byTooltip('Save')));

    expect(onCard(firstPost, find.byTooltip('Unsave')), findsOneWidget);
    final server = container.read(fakeServerProvider);
    final serverView = await server.getFeed('u_demo', limit: 1);
    expect(serverView.posts.single.bookmarkedAt, testNow);
  });

  testWidgets('scrolling to the end pages in every post, then says so', (
    tester,
  ) async {
    final container = await pumpConnectHub(tester);

    await tester.scrollUntilVisible(
      find.text("You're all caught up"),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final feed = container.read(feedControllerProvider).value!;
    expect(feed.posts, hasLength(17));
    expect(feed.loadMore, LoadMoreStatus.done);
  });

  testWidgets('offline, a refresh keeps the saved posts and says so', (
    tester,
  ) async {
    final container = await pumpConnectHub(tester);
    container.read(networkSimulatorProvider).failRequests = true;

    await pullToRefresh(tester);

    expect(find.text(FeedController.refreshFailedMessage), findsOneWidget);
    expect(firstPost, findsOneWidget);
  });

  testWidgets('offline from launch, the cache from the last launch shows, '
      'and the failed refresh says so', (tester) async {
    // A database that already holds a feed, as one would after a launch.
    final database = newTestDatabase();
    addTearDown(database.close);
    await tester.runAsync(
      () => database.feedDao.replaceFeed([cachedPost('p_cached')]),
    );

    await pumpConnectHub(
      tester,
      overrides: realStack(
        network: NetworkSimulator(latencyFactor: 0, failRequests: true),
        database: database,
      ),
    );

    expect(find.text('Post p_cached'), findsOneWidget);
    expect(find.text(FeedController.refreshFailedMessage), findsOneWidget);
  });

  testWidgets('offline from a first launch: the error, then "Try again" '
      'once back online', (tester) async {
    final network = NetworkSimulator(latencyFactor: 0, failRequests: true);
    await pumpConnectHub(tester, overrides: realStack(network: network));

    expect(find.text('Try again'), findsOneWidget);

    network.failRequests = false;
    await tester.tapAndSettle(find.text('Try again'));

    expect(firstPost, findsOneWidget);
  });
}
