import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/model/comment.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/features/post_detail/post_detail_controller.dart';
import 'package:connect_hub_riverpod/features/post_detail/post_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_comment_repository.dart';
import '../../helpers/fakes/fake_post_repository.dart';
import '../../helpers/fixtures.dart';

// PostDetailController without widgets: a family member per post id, fake
// repositories through overrides, every state recorded in order.
void main() {
  late FakePostRepository posts;
  late FakeCommentRepository comments;
  late ProviderContainer container;
  late List<String> states;

  final p1 = samplePost('p1');
  final c1 = sampleComment('c1');
  final c2 = sampleComment('c2');

  String describe(AsyncValue<PostDetailState> value) => switch (value) {
    AsyncData(value: final detail) => [
      'data ${detail.post.id} ♥${detail.post.likeCount}',
      '[${detail.comments.map((comment) => comment.id).join(',')}]',
      if (detail.isSending) 'sending',
      if (detail.sentCount > 0) 'sent ${detail.sentCount}',
      if (detail.message case final message?) '"$message"',
    ].join(' '),
    AsyncValue(isLoading: true) => 'loading',
    AsyncError(:final error) => 'error ${error.runtimeType}',
    _ => 'loading',
  };

  void start({Post? cached, List<Comment> cachedComments = const []}) {
    posts = FakePostRepository(cached: cached);
    comments = FakeCommentRepository(cached: cachedComments);
    container = testContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(posts),
        commentRepositoryProvider.overrideWithValue(comments),
      ],
    );
    states = [];
    container.listen(
      postDetailControllerProvider('p1'),
      (_, next) => states.add(describe(next)),
      fireImmediately: true,
    );
  }

  PostDetailController controller() =>
      container.read(postDetailControllerProvider('p1').notifier);

  tearDown(() async {
    await posts.dispose();
    await comments.dispose();
  });

  group('loading', () {
    test('a cached post shows at once, then the refresh behind it updates '
        'it', () async {
      start(cached: p1, cachedComments: [c1]);
      posts.refreshedPost = p1.copyWith(likeCount: 11);
      comments.refreshedComments = [c1, c2];

      await pumpEventQueue();

      expect(states.first, 'loading');
      expect(states[1], 'data p1 ♥10 [c1]');
      expect(states.last, 'data p1 ♥11 [c1,c2]');
      expect(posts.refreshCalls, 1);
      expect(comments.refreshCalls, 1);
    });

    test('not cached: loading until the server answers', () async {
      start();
      posts
        ..refreshGate = Completer<void>()
        ..refreshedPost = p1;
      comments.refreshedComments = [c1];

      await pumpEventQueue();
      expect(states, ['loading']);

      posts.refreshGate!.complete();
      await pumpEventQueue();
      expect(states, ['loading', 'data p1 ♥10 [c1]']);
    });

    test('a post the server no longer has: NotFoundException', () async {
      start();
      posts.refreshResult = const Err(NotFoundException());

      await pumpEventQueue();

      expect(states, ['loading', 'error NotFoundException']);
    });

    test('a cached post the server no longer has goes too', () async {
      start(cached: p1);
      posts.refreshResult = const Err(NotFoundException());

      await pumpEventQueue();

      expect(states.last, 'error NotFoundException');
    });

    test('not cached and the server fails: an error; "Try again" loads '
        'again', () async {
      start();
      posts.refreshResult = const Err(NetworkException());
      await pumpEventQueue();
      expect(states.last, 'error NetworkException');

      posts
        ..refreshResult = const Ok(null)
        ..refreshedPost = p1;
      container.invalidate(postDetailControllerProvider('p1'));
      await pumpEventQueue();

      expect(states.sublist(2), ['loading', 'data p1 ♥10 []']);
    });

    test('a failed refresh keeps the cached post and says so', () async {
      start(cached: p1);
      posts.refreshResult = const Err(NetworkException());

      await pumpEventQueue();

      expect(
        states.last,
        'data p1 ♥10 [] "${PostDetailController.refreshFailedMessage}"',
      );
    });

    test('comments that failed to load are reported; the post shows', () async {
      start();
      posts.refreshedPost = p1;
      comments.refreshResult = const Err(NetworkException());

      await pumpEventQueue();

      expect(
        states.last,
        'data p1 ♥10 [] "${PostDetailController.commentsFailedMessage}"',
      );
    });
  });

  group('live', () {
    test('a like elsewhere (the feed) updates the post in place', () async {
      start(cached: p1);
      await pumpEventQueue();

      posts.replacePost(p1.copyWith(likeCount: 99, isLiked: true));
      await pumpEventQueue();

      expect(states.last, startsWith('data p1 ♥99'));
    });
  });

  group('sending a comment', () {
    test('sending, then listed and counted as sent', () async {
      start(cached: p1, cachedComments: [c1]);
      await pumpEventQueue();
      comments
        ..addGate = Completer<void>()
        ..addedComment = sampleComment('c9', isMine: true);

      final sending = controller().sendComment('Nice!');
      await pumpEventQueue();
      expect(states.last, 'data p1 ♥10 [c1] sending');

      comments.addGate!.complete();
      await sending;
      expect(states.last, 'data p1 ♥10 [c1,c9] sent 1');
      expect(comments.addCalls, [(postId: 'p1', text: 'Nice!')]);
    });

    test('a failure keeps the text (nothing sent) and says why', () async {
      start(cached: p1);
      await pumpEventQueue();
      comments.addResult = const Err(NetworkException());

      await controller().sendComment('Nice!');

      expect(
        states.last,
        'data p1 ♥10 [] "${PostDetailController.sendFailedMessage}"',
      );
    });

    test('blank text, or a second send while one is out, is ignored', () async {
      start(cached: p1);
      await pumpEventQueue();
      comments.addGate = Completer<void>();

      await controller().sendComment('   ');
      final first = controller().sendComment('One');
      await controller().sendComment('Two');
      comments.addGate!.complete();
      await first;

      expect(comments.addCalls, [(postId: 'p1', text: 'One')]);
    });
  });

  group('likes, saves and deletes', () {
    test('go through the repositories, toggled', () async {
      start(cached: p1, cachedComments: [c1]);
      await pumpEventQueue();

      await controller().toggleLike(p1);
      await controller().toggleSave(p1);
      await controller().toggleCommentLike(c1);
      await controller().deleteComment(c1);

      expect(posts.likeCalls, [(postId: 'p1', liked: true)]);
      expect(posts.bookmarkCalls, [(postId: 'p1', bookmarked: true)]);
      expect(comments.likeCalls, [(commentId: 'c1', liked: true)]);
      expect(comments.deleteCalls, ['c1']);
    });

    test('each failure says what failed', () async {
      start(cached: p1, cachedComments: [c1]);
      await pumpEventQueue();
      posts
        ..likeResult = const Err(NetworkException())
        ..bookmarkResult = const Err(NetworkException());
      comments
        ..likeResult = const Err(NetworkException())
        ..deleteResult = const Err(NetworkException());

      final messages = <String?>[];
      for (final action in [
        () => controller().toggleLike(p1),
        () => controller().toggleSave(p1),
        () => controller().toggleCommentLike(c1),
        () => controller().deleteComment(c1),
      ]) {
        await action();
        messages.add(
          container.read(postDetailControllerProvider('p1')).value!.message,
        );
        controller().messageShown();
      }

      expect(messages, [
        PostDetailController.likeFailedMessage,
        PostDetailController.saveFailedMessage,
        PostDetailController.likeFailedMessage,
        PostDetailController.deleteFailedMessage,
      ]);
    });
  });

  group('a family', () {
    test('each post id has its own controller and state', () async {
      start(cached: p1);
      await pumpEventQueue();

      // A second post, through the same repositories.
      posts.replacePost(samplePost('p2', likeCount: 50));
      final p2 = await container.read(
        postDetailControllerProvider('p2').future,
      );

      expect(p2.post.likeCount, 50);
      expect(
        container.read(postDetailControllerProvider('p1')).value!.post.id,
        'p1',
      );
      expect(
        postDetailControllerProvider('p1'),
        isNot(postDetailControllerProvider('p2')),
      );
      expect(
        postDetailControllerProvider('p1'),
        postDetailControllerProvider('p1'),
      );
    });

    test('auto-dispose: leaving a post frees its controller, not the '
        "others'", () async {
      posts = FakePostRepository(cached: p1)..replacePost(samplePost('p2'));
      comments = FakeCommentRepository();
      container = testContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(posts),
          commentRepositoryProvider.overrideWithValue(comments),
        ],
      );
      final first = container.listen(
        postDetailControllerProvider('p1'),
        (_, _) {},
      );
      container.listen(postDetailControllerProvider('p2'), (_, _) {});
      await pumpEventQueue();

      first.close();
      await pumpEventQueue();

      expect(
        container.read(postDetailControllerProvider('p1').exists),
        isFalse,
      );
      expect(container.read(cachedPostProvider('p1').exists), isFalse);
      expect(container.read(postDetailControllerProvider('p2').exists), isTrue);
    });

    test(
      'a comment sent as the page closes touches nothing (ref.mounted)',
      () async {
        posts = FakePostRepository(cached: p1);
        comments = FakeCommentRepository()
          ..addGate = Completer<void>()
          ..addResult = const Err(NetworkException());
        container = testContainer(
          overrides: [
            postRepositoryProvider.overrideWithValue(posts),
            commentRepositoryProvider.overrideWithValue(comments),
          ],
        );
        final page = container.listen(
          postDetailControllerProvider('p1'),
          (_, _) {},
        );
        await pumpEventQueue();

        final sending = container
            .read(postDetailControllerProvider('p1').notifier)
            .sendComment('Bye');
        page.close();
        await pumpEventQueue();
        comments.addGate!.complete();

        await expectLater(sending, completes);
      },
    );
  });
}
