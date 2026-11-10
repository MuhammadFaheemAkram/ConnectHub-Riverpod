import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/model/comment.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/features/post_detail/post_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_comment_repository.dart';
import '../../helpers/fakes/fake_post_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

// Post Detail in each state, opened by its deep link, with the post and
// comment repositories replaced by fakes.
void main() {
  late FakePostRepository posts;
  late FakeCommentRepository comments;

  final p1 = samplePost('p1', commentCount: 1);

  Future<void> pumpPost(
    WidgetTester tester, {
    Post? cached,
    List<Comment> cachedComments = const [],
    void Function()? before,
    bool settle = true,
  }) async {
    posts = FakePostRepository(cached: cached);
    comments = FakeCommentRepository(cached: cachedComments);
    before?.call();
    addTearDown(posts.dispose);
    addTearDown(comments.dispose);
    await pumpConnectHub(
      tester,
      at: '/posts/p1',
      overrides: [
        ...realStack(),
        postRepositoryProvider.overrideWithValue(posts),
        commentRepositoryProvider.overrideWithValue(comments),
      ],
      settle: settle,
    );
  }

  final input = find.byType(TextField);
  final onPost = appBarTitled('Post');

  testWidgets('loading: a spinner while an uncached post loads', (
    tester,
  ) async {
    await pumpPost(
      tester,
      before: () => posts
        ..refreshGate = Completer<void>()
        ..refreshedPost = p1,
      settle: false,
    );

    expect(find.text('Loading post…'), findsOneWidget);

    posts.refreshGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Post p1'), findsOneWidget);
  });

  testWidgets('not found: "This post is no longer available."', (tester) async {
    await pumpPost(
      tester,
      before: () => posts.refreshResult = const Err(NotFoundException()),
    );

    expect(find.text('This post is no longer available.'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('error: the reason and "Try again"', (tester) async {
    await pumpPost(
      tester,
      before: () => posts.refreshResult = const Err(NetworkException()),
    );
    expect(find.text(const NetworkException().message), findsOneWidget);

    posts
      ..refreshResult = const Ok(null)
      ..refreshedPost = p1;
    await tester.tapAndSettle(find.text('Try again'));

    expect(find.text('Post p1'), findsOneWidget);
  });

  testWidgets('loaded: the post, then its comments, oldest first', (
    tester,
  ) async {
    await pumpPost(
      tester,
      cached: p1,
      cachedComments: [sampleComment('c1'), sampleComment('c2')],
    );

    expect(onPost, findsOneWidget);
    expect(find.text('Post p1'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Comment c1')).dy,
      lessThan(tester.getTopLeft(find.text('Comment c2')).dy),
    );
  });

  testWidgets('no comments: an invitation to write the first', (tester) async {
    await pumpPost(tester, cached: p1);

    expect(
      find.text('No comments yet. Be the first to comment.'),
      findsOneWidget,
    );
  });

  group('the comment input', () {
    IconButton send(WidgetTester tester) => tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Send'),
        matching: find.byType(IconButton),
      ),
    );

    testWidgets('sends, shows progress, then clears and lists the comment', (
      tester,
    ) async {
      await pumpPost(tester, cached: p1);
      comments
        ..addGate = Completer<void>()
        ..addedComment = sampleComment('c9', isMine: true);

      await tester.enterText(input, 'Nice!');
      await tester.pump();
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();
      expect(find.bySemanticsLabel('Sending'), findsOneWidget);

      comments.addGate!.complete();
      await tester.pumpAndSettle();

      expect(comments.addCalls, [(postId: 'p1', text: 'Nice!')]);
      expect(find.text('Comment c9'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(tester.widget<TextField>(input).controller!.text, isEmpty);
      expect(send(tester).onPressed, isNull);
    });

    testWidgets('a long thread scrolls all the way to the new comment', (
      tester,
    ) async {
      await pumpPost(
        tester,
        cached: samplePost('p1', imageUrl: 'https://picsum.photos/600'),
        // Short comments near the top, long ones further down: the list
        // estimates the part it hasn't built from the part it has, and
        // underestimates (as on the simulator).
        cachedComments: [
          for (var i = 0; i < 12; i++)
            sampleComment(
              'c$i',
              minutesAgo: 60 - i,
            ).copyWith(text: i < 4 ? 'Short $i' : 'Long $i ' * 40),
        ],
      );
      comments.addedComment = sampleComment('c_new', isMine: true);
      // The keyboard is up while typing.
      tester.view.viewInsets = const FakeViewPadding(bottom: 336 * 3);
      addTearDown(tester.view.resetViewInsets);

      await tester.enterText(input, 'Last word');
      await tester.pump();
      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();

      final newest = tester.getRect(find.text('Comment c_new'));
      final list = tester.getRect(find.byType(ListView));
      expect(newest.bottom, lessThanOrEqualTo(list.bottom));
      expect(newest.top, greaterThanOrEqualTo(list.top));
    });

    testWidgets('a failure keeps the text and says why', (tester) async {
      await pumpPost(tester, cached: p1);
      comments.addResult = const Err(NetworkException());

      await tester.enterText(input, 'Nice!');
      await tester.pump();
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();

      expect(find.text(PostDetailController.sendFailedMessage), findsOneWidget);
      expect(tester.widget<TextField>(input).controller!.text, 'Nice!');
    });

    testWidgets("the post's comment button focuses the input", (tester) async {
      await pumpPost(tester, cached: p1);

      await tester.tapAndSettle(find.byTooltip('1 comment'));

      expect(tester.widget<TextField>(input).focusNode!.hasFocus, isTrue);
    });
  });

  group('my comments', () {
    testWidgets('Delete asks first; confirming deletes it', (tester) async {
      await pumpPost(
        tester,
        cached: p1,
        cachedComments: [sampleComment('c1', isMine: true)],
      );

      await tester.tapAndSettle(find.byTooltip('Comment options'));
      await tester.tapAndSettle(find.text('Delete'));
      expect(find.text('Delete comment?'), findsOneWidget);

      await tester.tapAndSettle(find.text('Cancel'));
      expect(comments.deleteCalls, isEmpty);

      await tester.tapAndSettle(find.byTooltip('Comment options'));
      await tester.tapAndSettle(find.text('Delete'));
      await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Delete'));
      expect(comments.deleteCalls, ['c1']);
      expect(find.text('Comment c1'), findsNothing);
    });

    testWidgets("someone else's comment has no options", (tester) async {
      await pumpPost(tester, cached: p1, cachedComments: [sampleComment('c1')]);

      expect(find.byTooltip('Comment options'), findsNothing);
    });
  });

  testWidgets('a comment like reaches the repository', (tester) async {
    await pumpPost(tester, cached: p1, cachedComments: [sampleComment('c1')]);

    await tester.tapAndSettle(find.byTooltip('Like comment'));

    expect(comments.likeCalls, [(commentId: 'c1', liked: true)]);
  });

  testWidgets('opened by a link, Back goes to the feed', (tester) async {
    await pumpPost(tester, cached: p1);

    await tester.tapAndSettle(find.byTooltip('Go to the feed'));

    expect(appBarTitled('ConnectHub'), findsOneWidget);
  });
}
