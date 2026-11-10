import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/id_generator.dart';
import 'package:connect_hub_riverpod/core/network/asset_json_loader.dart';
import 'package:connect_hub_riverpod/core/network/dto/create_post_request_dto.dart';
import 'package:connect_hub_riverpod/core/network/dto/post_dto.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/seed_loader.dart';
import 'package:connect_hub_riverpod/domain/model/app_notification.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/backend.dart';

void main() {
  // The real bundled seed JSON, read through the test asset bundle.
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeServer server;

  setUp(() => server = newFakeServer());

  /// Every post, page by page, as [viewer] sees them.
  Future<List<PostDto>> allPosts({String viewer = 'u_demo'}) async {
    final posts = <PostDto>[];
    String? cursor;
    do {
      final page = await server.getFeed(viewer, cursor: cursor, limit: 6);
      posts.addAll(page.posts);
      cursor = page.nextCursor;
    } while (cursor != null);
    return posts;
  }

  /// Every post, [size] at a time.
  Future<List<PostDto>> allPostsInPagesOf(int size) async {
    final posts = <PostDto>[];
    String? cursor;
    do {
      final page = await server.getFeed('u_demo', cursor: cursor, limit: size);
      posts.addAll(page.posts);
      cursor = page.nextCursor;
    } while (cursor != null);
    return posts;
  }

  Future<PostDto> post(String id, {String viewer = 'u_demo'}) async =>
      (await allPosts(viewer: viewer)).singleWhere((post) => post.id == id);

  group('seed', () {
    test('the demo user is the one signed in', () async {
      final demo = await SeedLoader(AssetJsonLoader(rootBundle)).loadAuthUser();

      expect(demo.id, 'u_demo');
      expect(demo.name, 'Demo User');
      expect(await server.signedInUserId(), 'u_demo');
    });

    test('the 15 iOS posts plus the demo user\'s 2 are all served', () async {
      final posts = await allPosts();

      expect(posts, hasLength(17));
      expect(
        posts.where((post) => post.author.id == 'u_demo').map((p) => p.id),
        ['p16', 'p17'],
      );
    });

    test('dates are rebased so the newest seed record is five minutes old, '
        'and the gaps between records are kept', () async {
      final posts = await allPosts();
      DateTime createdAt(String id) =>
          posts.singleWhere((post) => post.id == id).createdAt;

      // The newest seed record, across every file, is notification n1
      // (July 24, 11:10). p1 was posted 2h55m before it, and p2 1h35m
      // before p1. (Before Phase 4 brought the notifications in, it was
      // comment c13, and p1 was 2h15m older than "five minutes ago".)
      final newest = testNow.subtract(FakeServer.newestSeedAge);
      expect(
        createdAt('p1'),
        newest.subtract(const Duration(hours: 2, minutes: 55)),
      );
      expect(
        createdAt('p1').difference(createdAt('p2')),
        const Duration(hours: 1, minutes: 35),
      );
      final notifications = await server.getNotifications('u_demo');
      expect(notifications.first.id, 'n1');
      expect(notifications.first.createdAt, newest);
    });

    test('comment counts are derived from the comments, not the seed\'s '
        'numbers', () async {
      final posts = {for (final post in await allPosts()) post.id: post};

      // The iOS seed claims 18 comments on p1, 64 on p2 and 129 on p5.
      expect(posts['p1']!.commentCount, 3);
      expect(posts['p2']!.commentCount, 3);
      expect(posts['p5']!.commentCount, 2);
      expect(posts['p16']!.commentCount, 1);
      expect(posts['p4']!.commentCount, 0);
    });

    test('authors are public profiles: they never carry an email', () async {
      final posts = await allPosts();

      expect(posts.map((post) => post.author.email), everyElement(isNull));
      expect((await post('p16')).author.name, 'Demo User');
    });
  });

  group('feed pages', () {
    test('come newest first, in pages of 6 / 6 / 5 with no overlap', () async {
      final first = await server.getFeed('u_demo', limit: 6);
      final second = await server.getFeed(
        'u_demo',
        cursor: first.nextCursor,
        limit: 6,
      );
      final third = await server.getFeed(
        'u_demo',
        cursor: second.nextCursor,
        limit: 6,
      );

      List<String> ids(List<PostDto> posts) => [for (final p in posts) p.id];
      expect(ids(first.posts), ['p1', 'p2', 'p3', 'p16', 'p4', 'p5']);
      expect(ids(second.posts), ['p6', 'p7', 'p17', 'p8', 'p9', 'p10']);
      expect(ids(third.posts), ['p11', 'p12', 'p13', 'p14', 'p15']);
      expect(first.nextCursor, isNotNull);
      expect(second.nextCursor, isNotNull);
      expect(third.nextCursor, isNull);
    });

    test(
      'a page that ends exactly at the last post has no next cursor',
      () async {
        final everything = await server.getFeed('u_demo', limit: 17);

        expect(everything.posts, hasLength(17));
        expect(everything.nextCursor, isNull);
      },
    );

    test('posts made at the same moment page in by id, none skipped or '
        'repeated', () async {
      // Three posts at one instant, paged one at a time: only the id can
      // tell the cursor where the next page starts.
      const at = '2026-07-24T08:00:00Z';
      String post(String id) =>
          '{"id": "$id", "author": {"id": "u_ada", "name": "Ada"}, '
          '"content": "$id", "createdAt": "$at", "likeCount": 0, '
          '"commentCount": 0}';
      server = FakeServer(
        SeedLoader(
          AssetJsonLoader(
            _JsonBundle({
              SeedLoader.authUserPath: '{"id": "u_demo", "name": "Demo"}',
              SeedLoader.postsPath:
                  '[${post('pa')}, ${post('pc')}, ${post('pb')}]',
              SeedLoader.commentsPath: '[]',
              SeedLoader.notificationsPath: '[]',
            }),
          ),
        ),
        IdGenerator(),
        Clock.fixed(testNow),
      );

      final ids = [for (final post in await allPostsInPagesOf(1)) post.id];

      expect(ids, ['pc', 'pb', 'pa']);
    });

    test('a cursor it never issued is rejected', () {
      expect(
        server.getFeed('u_demo', cursor: 'page-2', limit: 6),
        throwsFormatException,
      );
    });
  });

  group('likes', () {
    test('liking adds one like, and liking again changes nothing', () async {
      final liked = await server.setLiked('u_demo', 'p1', liked: true);
      final again = await server.setLiked('u_demo', 'p1', liked: true);

      expect(liked.isLiked, isTrue);
      expect(liked.likeCount, 143);
      expect(again.likeCount, 143);
    });

    test('unliking removes the like', () async {
      await server.setLiked('u_demo', 'p1', liked: true);

      final unliked = await server.setLiked('u_demo', 'p1', liked: false);

      expect(unliked.isLiked, isFalse);
      expect(unliked.likeCount, 142);
    });

    test(
      "are per user: others see the count, not the viewer's heart",
      () async {
        await server.setLiked('u_demo', 'p1', liked: true);

        final seenByOther = await post('p1', viewer: 'u_other');

        expect(seenByOther.likeCount, 143);
        expect(seenByOther.isLiked, isFalse);
        expect((await post('p1')).isLiked, isTrue);
      },
    );

    test('an unknown post is not found', () {
      expect(
        server.setLiked('u_demo', 'p999', liked: true),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('bookmarks (saves)', () {
    test('are per user and remember when they were made', () async {
      final bookmarked = await server.setBookmarked(
        'u_demo',
        'p3',
        bookmarked: true,
      );

      expect(bookmarked.bookmarkedAt, testNow);
      expect((await post('p3', viewer: 'u_other')).bookmarkedAt, isNull);
    });

    test(
      'bookmarking again keeps the original time; removing clears it',
      () async {
        var now = testNow;
        server = newFakeServer(clock: Clock(() => now));
        await server.setBookmarked('u_demo', 'p3', bookmarked: true);

        now = now.add(const Duration(hours: 1));
        final repeated = await server.setBookmarked(
          'u_demo',
          'p3',
          bookmarked: true,
        );
        expect(repeated.bookmarkedAt, testNow);

        final removed = await server.setBookmarked(
          'u_demo',
          'p3',
          bookmarked: false,
        );
        expect(removed.bookmarkedAt, isNull);
      },
    );
  });

  group('one post', () {
    test('comes as the viewer sees it', () async {
      await server.setLiked('u_demo', 'p3', liked: true);

      final post = await server.getPost('u_demo', 'p3');

      expect(post.id, 'p3');
      expect(post.isLiked, isTrue);
      expect(post.commentCount, 2);
    });

    test('an unknown one is not found', () {
      expect(
        server.getPost('u_demo', 'p999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('create post', () {
    test(
      'publishes it as the viewer, trimmed, at the top of the first page',
      () async {
        final created = await server.createPost(
          'u_demo',
          const CreatePostRequestDto(
            content: '  Hello, ConnectHub!  ',
            imageUrl: ' https://picsum.photos/600/400 ',
          ),
        );

        expect(created.author.id, 'u_demo');
        expect(created.content, 'Hello, ConnectHub!');
        expect(created.imageUrl, 'https://picsum.photos/600/400');
        expect(created.createdAt, testNow);
        expect(created.likeCount, 0);
        expect(created.commentCount, 0);
        final firstPage = await server.getFeed('u_demo', limit: 6);
        expect(firstPage.posts.first.id, created.id);
      },
    );

    test('an empty image URL means no image', () async {
      final created = await server.createPost(
        'u_demo',
        const CreatePostRequestDto(content: 'No picture', imageUrl: ''),
      );

      expect(created.imageUrl, isNull);
    });

    test('a request that breaks the rules is rejected (a 400)', () {
      for (final request in [
        const CreatePostRequestDto(content: '   '),
        CreatePostRequestDto(content: 'a' * 281),
        const CreatePostRequestDto(content: 'Hi', imageUrl: 'not a url'),
      ]) {
        expect(
          server.createPost('u_demo', request),
          throwsFormatException,
          reason: request.content,
        );
      }
    });
  });

  group('comments', () {
    test('come oldest first, each with its author', () async {
      final comments = await server.getComments('u_demo', 'p1');

      expect([for (final c in comments) c.id], ['c1', 'c2', 'c3']);
      expect(comments.first.author.name, 'Grace Hopper');
    });

    test('an unknown post has no comments to list', () {
      expect(
        server.getComments('u_demo', 'p999'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'adding one stores it trimmed, as the viewer, and counts it',
      () async {
        final comment = await server.addComment(
          'u_demo',
          'p4',
          '  Great point!  ',
        );

        expect(comment.text, 'Great point!');
        expect(comment.author.id, 'u_demo');
        expect(comment.createdAt, testNow);
        expect((await server.getPost('u_demo', 'p4')).commentCount, 1);
        expect(
          (await server.getComments('u_demo', 'p4')).single.id,
          comment.id,
        );
      },
    );

    test('a blank or too long comment is rejected (a 400)', () {
      expect(server.addComment('u_demo', 'p4', '  '), throwsFormatException);
      expect(
        server.addComment('u_demo', 'p4', 'a' * 501),
        throwsFormatException,
      );
    });

    test('only its author may delete it: anyone else gets a 404', () async {
      final mine = await server.addComment('u_demo', 'p4', 'Mine');

      expect(
        server.deleteComment('u_other', mine.id),
        throwsA(isA<NotFoundException>()),
      );
      // c1 is Grace Hopper's.
      expect(
        server.deleteComment('u_demo', 'c1'),
        throwsA(isA<NotFoundException>()),
      );

      await server.deleteComment('u_demo', mine.id);
      expect((await server.getPost('u_demo', 'p4')).commentCount, 0);
    });
  });

  group('comment likes', () {
    test("the seed's comments carry the table's likes; others start at "
        '0', () async {
      final comments = {
        for (final comment in await server.getComments('u_demo', 'p1'))
          comment.id: comment.likeCount,
      };

      expect(comments, {'c1': 4, 'c2': 12, 'c3': 1});
      final added = await server.addComment('u_demo', 'p1', 'Hi');
      expect(added.likeCount, 0);
    });

    test('liking adds one like, and liking again changes nothing', () async {
      final liked = await server.setCommentLiked('u_demo', 'c1', liked: true);
      final again = await server.setCommentLiked('u_demo', 'c1', liked: true);

      expect(liked.isLiked, isTrue);
      expect(liked.likeCount, 5);
      expect(again.likeCount, 5);
    });

    test(
      "are per user: others see the count, not the viewer's heart",
      () async {
        await server.setCommentLiked('u_demo', 'c1', liked: true);

        final seenByOther = (await server.getComments('u_other', 'p1')).first;

        expect(seenByOther.likeCount, 5);
        expect(seenByOther.isLiked, isFalse);
      },
    );

    test('unliking removes it; an unknown comment is not found', () async {
      await server.setCommentLiked('u_demo', 'c1', liked: true);

      final unliked = await server.setCommentLiked(
        'u_demo',
        'c1',
        liked: false,
      );

      expect(unliked.likeCount, 4);
      expect(
        server.setCommentLiked('u_demo', 'c999', liked: true),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('search', () {
    /// Searches as the demo user and checks the ids found, in order.
    Future<void> expectFound(
      String query, {
      List<String> people = const [],
      List<String> posts = const [],
    }) async {
      final response = await server.search('u_demo', query);
      expect(
        [for (final user in response.users) user.id],
        people,
        reason: 'people matching "$query"',
      );
      expect(
        [for (final post in response.posts) post.id],
        posts,
        reason: 'posts matching "$query"',
      );
    }

    test(
      'finds people by name and posts by their author, ignoring case',
      () async {
        await expectFound('ada', people: ['u_ada'], posts: ['p1', 'p6', 'p11']);
        await expectFound(
          '  ADA ',
          people: ['u_ada'],
          posts: ['p1', 'p6', 'p11'],
        );
      },
    );

    test('finds people by bio, and posts by content', () async {
      await expectFound('moon', people: ['u_katherine']);
      await expectFound('cache', posts: ['p15']);
    });

    test(
      'lists the most followed people first, and posts newest first',
      () async {
        final response = await server.search('u_demo', 'in');

        expect(response.users.map((user) => user.id), [
          'u_linus',
          'u_alan',
          'u_katherine',
        ]);
        expect(response.posts.take(4).map((post) => post.id), [
          'p1',
          'p2',
          'p3',
          'p16',
        ]);
      },
    );

    test('leaves the viewer out of the people, not out of the posts', () async {
      await expectFound('demo', posts: ['p16', 'p17', 'p8']);
    });

    test('a blank query, or one nothing matches, finds nothing', () async {
      await expectFound('   ');
      await expectFound('zzz');
    });
  });

  group('notifications', () {
    test('newest first, with their read state and links', () async {
      final notifications = await server.getNotifications('u_demo');

      expect(notifications.map((n) => n.id), [
        'n1',
        'n2',
        'n3',
        'n4',
        'n5',
        'n6',
        'n7',
        'n8',
      ]);
      expect(notifications.where((n) => !n.isRead).map((n) => n.id), [
        'n1',
        'n2',
        'n3',
      ]);
      expect(notifications[0].postId, 'p16');
      expect(notifications[2].userId, 'u_katherine');
      expect(notifications[5].postId, isNull);
      expect(notifications[5].userId, isNull);
      expect(notifications.first.kind.name, NotificationKind.like.name);
    });

    test(
      'the read state belongs to the server: marking one read sticks',
      () async {
        await server.markNotificationRead('u_demo', 'n1');
        // Idempotent.
        await server.markNotificationRead('u_demo', 'n1');

        final n1 = (await server.getNotifications('u_demo')).first;
        expect(n1.isRead, isTrue);
      },
    );

    test(
      "someone else's notification, like an unknown one, answers 404",
      () async {
        expect(
          server.markNotificationRead('u_ada', 'n1'),
          throwsA(isA<NotFoundException>()),
        );
        expect(
          server.markNotificationRead('u_demo', 'n404'),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test('mark all read', () async {
      await server.markAllNotificationsRead('u_demo');

      final notifications = await server.getNotifications('u_demo');
      expect(notifications.every((n) => n.isRead), isTrue);
    });
  });

  group('users', () {
    test('a profile is public: no email', () async {
      final demo = await server.getUser('u_demo');

      expect(demo.name, 'Demo User');
      expect(demo.email, isNull);
    });

    test("a user's posts: all of them, newest first, as the viewer sees "
        'them', () async {
      await server.setLiked('u_demo', 'p1', liked: true);

      final posts = await server.getUserPosts('u_demo', 'u_ada');

      expect(posts.map((post) => post.id), ['p1', 'p6', 'p11']);
      expect(posts.first.isLiked, isTrue);
    });

    test('an unknown user, and so their posts, are not found', () {
      expect(server.getUser('u_nobody'), throwsA(isA<NotFoundException>()));
      expect(
        server.getUserPosts('u_demo', 'u_nobody'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('saved posts', () {
    test("the viewer's own, the most recently saved first", () async {
      var now = testNow;
      server = FakeServer(
        SeedLoader(AssetJsonLoader(rootBundle)),
        IdGenerator(),
        Clock(() => now),
      );
      expect(await server.getBookmarks('u_demo'), isEmpty);

      for (final id in ['p7', 'p2', 'p12']) {
        await server.setBookmarked('u_demo', id, bookmarked: true);
        now = now.add(const Duration(minutes: 1));
      }
      await server.setBookmarked('u_other', 'p5', bookmarked: true);

      final saved = await server.getBookmarks('u_demo');
      expect(saved.map((post) => post.id), ['p12', 'p2', 'p7']);
    });
  });
}

/// An asset bundle that serves JSON strings from memory.
class _JsonBundle extends CachingAssetBundle {
  _JsonBundle(this._files);

  final Map<String, String> _files;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(_files[key]!)));
}
