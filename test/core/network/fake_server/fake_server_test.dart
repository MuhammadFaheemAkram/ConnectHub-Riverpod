import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/network/asset_json_loader.dart';
import 'package:connect_hub_riverpod/core/network/dto/post_dto.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/seed_loader.dart';
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

      // The newest seed record (posts and comments; Phase 4 adds the
      // notifications) is comment c13 (July 24, 10:30). p1 was posted 2h15m
      // before it, and p2 1h35m before p1.
      final newest = testNow.subtract(FakeServer.newestSeedAge);
      expect(
        createdAt('p1'),
        newest.subtract(const Duration(hours: 2, minutes: 15)),
      );
      expect(
        createdAt('p1').difference(createdAt('p2')),
        const Duration(hours: 1, minutes: 35),
      );
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
            }),
          ),
        ),
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
}

/// An asset bundle that serves JSON strings from memory.
class _JsonBundle extends CachingAssetBundle {
  _JsonBundle(this._files);

  final Map<String, String> _files;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(_files[key]!)));
}
