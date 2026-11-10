import 'dart:async';

import 'package:clock/clock.dart';
import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/data_stack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack backend;

  /// The client's clock runs a minute ahead of the server's, so a local
  /// guess and the server's answer are told apart.
  final clientNow = testNow.add(const Duration(minutes: 1));

  setUp(() async {
    backend = DataStack(clientClock: Clock.fixed(clientNow));
    await backend.feed.refresh();
  });

  Future<Post> cached(String id) async => (await backend.feed.watchFeed().first)
      .singleWhere((post) => post.id == id);

  Matcher isErr(Matcher exception) =>
      isA<Err<void>>().having((err) => err.exception, 'exception', exception);

  group('likes', () {
    test('the heart and count change at once, then take the server\'s '
        'numbers', () async {
      backend.api.gate = Completer<void>();

      final liking = backend.posts.setLiked('p1', liked: true);
      await pumpEventQueue();
      // Optimistic: the server hasn't answered yet.
      expect((await cached('p1')).isLiked, isTrue);
      expect((await cached('p1')).likeCount, 143);

      // Someone else likes it meanwhile; the server's count includes them.
      await backend.server.setLiked('u_other', 'p1', liked: true);
      backend.api.gate!.complete();

      expect(await liking, isA<Ok<void>>());
      expect((await cached('p1')).likeCount, 144);
    });

    test('a failure rolls back and says why', () async {
      backend.network.failRequests = true;

      final result = await backend.posts.setLiked('p1', liked: true);

      expect(result, isErr(isA<NetworkException>()));
      final p1 = await cached('p1');
      expect(p1.isLiked, isFalse);
      expect(p1.likeCount, 142);
    });

    test('a second tap while the first is in flight is ignored', () async {
      backend.api.gate = Completer<void>();

      final first = backend.posts.setLiked('p1', liked: true);
      final second = await backend.posts.setLiked('p1', liked: false);
      backend.api.gate!.complete();
      await first;

      expect(second, isA<Ok<void>>());
      expect(backend.api.requests.where((r) => r == 'like:p1'), hasLength(1));
      expect((await cached('p1')).isLiked, isTrue);
    });

    test('regression: a like keeps the post\'s bookmark', () async {
      await backend.posts.setBookmarked('p1', bookmarked: true);

      await backend.posts.setLiked('p1', liked: true);

      expect((await cached('p1')).isBookmarked, isTrue);
    });
  });

  group('saves (bookmarks)', () {
    Future<DateTime?> bookmarkedAt(String id) async {
      final query = backend.database.select(backend.database.bookmarks)
        ..where((bookmark) => bookmark.postId.equals(id));
      return (await query.getSingleOrNull())?.bookmarkedAt;
    }

    test('show at once, then take the server\'s time', () async {
      backend.api.gate = Completer<void>();

      final bookmarking = backend.posts.setBookmarked('p3', bookmarked: true);
      await pumpEventQueue();
      expect(await bookmarkedAt('p3'), clientNow);

      backend.api.gate!.complete();
      await bookmarking;
      expect(await bookmarkedAt('p3'), testNow);
    });

    test('a failed removal puts the bookmark back as it was', () async {
      await backend.posts.setBookmarked('p3', bookmarked: true);
      backend.network.failRequests = true;

      final result = await backend.posts.setBookmarked('p3', bookmarked: false);

      expect(result, isErr(isA<NetworkException>()));
      expect(await bookmarkedAt('p3'), testNow);
    });
  });
}
