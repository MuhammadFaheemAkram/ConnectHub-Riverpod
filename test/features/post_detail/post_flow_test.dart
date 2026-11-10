import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:connect_hub_riverpod/features/post_detail/post_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/pump_app.dart';

// Posts and comments end to end, on the real provider graph: the fake
// server, drift (in memory), the repositories, the controllers and pages.
void main() {
  // p1, the newest post in the seed: Ada Lovelace's, 142 likes, 3 comments.
  final firstPost = find.textContaining('analytical engine scheduler');
  final onFeed = appBarTitled('ConnectHub');
  final onPost = appBarTitled('Post');
  final input = find.byType(TextField);

  Finder onCard(Finder post, Finder target) => find.descendant(
    of: find.ancestor(of: post, matching: find.byType(Card)),
    matching: target,
  );

  Future<void> openFirstPost(WidgetTester tester) async {
    await tester.tapAndSettle(firstPost);
    expect(onPost, findsOneWidget);
  }

  Future<void> comment(WidgetTester tester, String text) async {
    await tester.enterText(input, text);
    await tester.pump();
    await tester.tapAndSettle(find.byTooltip('Send'));
  }

  Future<void> back(WidgetTester tester) =>
      tester.tapAndSettle(find.byType(BackButton));

  testWidgets('a post from the feed opens with its comments, oldest first, '
      'with their likes', (tester) async {
    await pumpConnectHub(tester);
    // Tall enough for the post (with its image) and every comment: a list
    // only builds what is on screen (conventions §11.51).
    tester.view.physicalSize = const Size(390 * 3, 2000 * 3);

    await openFirstPost(tester);

    expect(find.text('Grace Hopper'), findsWidgets);
    expect(find.byTooltip('Like comment'), findsNWidgets(3));
    // c1's seed likes, from the server's table.
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets("a comment shows at once, and updates the feed's count", (
    tester,
  ) async {
    await pumpConnectHub(tester);
    expect(onCard(firstPost, find.byTooltip('3 comments')), findsOneWidget);
    await openFirstPost(tester);

    await comment(tester, 'Naming is hard indeed.');

    expect(find.text('Naming is hard indeed.'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    await back(tester);
    expect(onFeed, findsOneWidget);
    expect(onCard(firstPost, find.byTooltip('4 comments')), findsOneWidget);
  });

  testWidgets('deleting my comment takes it off the post and the feed', (
    tester,
  ) async {
    await pumpConnectHub(tester);
    await openFirstPost(tester);
    await comment(tester, 'Oops');

    await tester.tapAndSettle(find.byTooltip('Comment options'));
    await tester.tapAndSettle(find.text('Delete'));
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Delete'));

    expect(find.text('Oops'), findsNothing);
    await back(tester);
    expect(onCard(firstPost, find.byTooltip('3 comments')), findsOneWidget);
  });

  testWidgets('a like on the post shows on the feed: one row in drift', (
    tester,
  ) async {
    await pumpConnectHub(tester);
    await openFirstPost(tester);

    await tester.tapAndSettle(onCard(firstPost, find.byTooltip('Like')));
    await back(tester);

    expect(onCard(firstPost, find.byTooltip('Unlike')), findsOneWidget);
    expect(onCard(firstPost, find.text('143')), findsOneWidget);
  });

  testWidgets('a comment like is kept by the server', (tester) async {
    final container = await pumpConnectHub(tester);
    await openFirstPost(tester);

    await tester.tapAndSettle(find.byTooltip('Like comment').first);

    expect(find.byTooltip('Unlike comment'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    final server = container.read(fakeServerProvider);
    final c1 = (await server.getComments('u_demo', 'p1')).first;
    expect(c1.isLiked, isTrue);
  });

  testWidgets('offline, a comment that fails stays in the field', (
    tester,
  ) async {
    final container = await pumpConnectHub(tester);
    await openFirstPost(tester);
    container.read(networkSimulatorProvider).failRequests = true;

    await comment(tester, 'Will this send?');

    expect(find.text(PostDetailController.sendFailedMessage), findsOneWidget);
    expect(tester.widget<TextField>(input).controller!.text, 'Will this send?');
  });

  testWidgets('a new post heads the feed, by me', (tester) async {
    await pumpConnectHub(tester);

    await tester.tapAndSettle(find.byTooltip('New post'));
    await tester.enterText(
      find.widgetWithText(TextField, "What's on your mind?"),
      'Hello from the Riverpod edition!',
    );
    await tester.pump();
    await tester.tapAndSettle(find.text('Post'));

    expect(onFeed, findsOneWidget);
    final newPost = find.text('Hello from the Riverpod edition!');
    expect(newPost, findsOneWidget);
    expect(onCard(newPost, find.text('Demo User')), findsOneWidget);
    expect(
      tester.getTopLeft(newPost).dy,
      lessThan(tester.getTopLeft(firstPost).dy),
    );
  });

  testWidgets('a link to a post that is not cached loads it, and its '
      'comments', (tester) async {
    // p10 is on the feed's second page: not cached at launch.
    await pumpConnectHub(tester, at: '/posts/p10');

    expect(onPost, findsOneWidget);
    expect(find.byTooltip('Like comment'), findsOneWidget);
  });

  testWidgets('a link to a post that does not exist says so', (tester) async {
    await pumpConnectHub(tester, at: '/posts/p999');

    expect(find.text('This post is no longer available.'), findsOneWidget);
  });
}
