import 'package:clock/clock.dart';
import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/network/dto/post_dto.dart';
import 'package:connect_hub_riverpod/core/network/dto/post_page_dto.dart';
import 'package:connect_hub_riverpod/core/network/dto/user_dto.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/seed_loader.dart';

/// An in-memory stand-in for ConnectHub's backend.
///
/// It plays the role a REST server would: it owns the data and its rules
/// (profiles, posts, likes, bookmarks, and from later phases comments,
/// search and notifications). The rest of the app reaches it **only**
/// through the `…ApiService` interfaces, so a real HTTP client could replace
/// the fake services without changing any caller.
///
/// It lives in memory and seeds itself from the bundled JSON on first use, so
/// every launch starts from the same seed: likes and saves last until the app
/// restarts. That's deliberate: the backend is not the point of this project;
/// how the app talks to it is.
///
/// Ported from ConnectHub-Flutter and trimmed: no accounts or tokens (the
/// demo user is always signed in), no chat. Transport concerns (latency,
/// simulated failures) live in the fake API layer, not here.
class FakeServer {
  FakeServer(this._seeds, this._clock);

  final SeedLoader _seeds;
  final Clock _clock;

  Future<void>? _seeding;

  /// The demo user's id, from the seed.
  late final String _signedInUserId;

  /// Public profiles by user id.
  final _users = <String, UserDto>{};

  /// Posts by id.
  final _posts = <String, _ServerPost>{};

  /// How many comments each post has (by post id). Phase 3 replaces the
  /// counts with the comments themselves.
  final _commentCounts = <String, int>{};

  /// How old the newest seed record is at launch (see [_seed]).
  static const newestSeedAge = Duration(minutes: 5);

  /// The user every request is made as: the demo user, always signed in.
  Future<String> signedInUserId() async {
    await _ready();
    return _signedInUserId;
  }

  // ---------------------------------------------------------------------------
  // Feed

  /// One page of the feed as [viewerId] sees it: newest first, ties broken by
  /// id, starting after [cursor] (or at the top when it is `null`).
  ///
  /// The cursor marks a *position* ("older than this post"), not an offset.
  /// A post created after page 1 was fetched lands above that position, so
  /// page 2 neither repeats nor skips anything. With offsets, every new post
  /// would shift the following pages by one.
  Future<PostPageDto> getFeed(
    String viewerId, {
    String? cursor,
    required int limit,
  }) async {
    await _ready();
    final after = cursor == null ? null : _Cursor.decode(cursor);
    final older = [
      for (final post in _postsNewestFirst())
        if (after == null || after.isNewerThan(post)) post,
    ];
    final page = older.take(limit).toList();
    return PostPageDto(
      posts: [for (final post in page) _postDto(post, viewerId)],
      nextCursor: older.length > page.length
          ? _Cursor.at(page.last).encode()
          : null,
    );
  }

  /// Likes or unlikes a post for [viewerId] and returns the updated post.
  ///
  /// Idempotent, like an HTTP `PUT`/`DELETE`: liking twice still counts one
  /// like, so a retried request can't inflate the count.
  Future<PostDto> setLiked(
    String viewerId,
    String postId, {
    required bool liked,
  }) async {
    await _ready();
    final post = _post(postId);
    if (liked) {
      post.likedBy.add(viewerId);
    } else {
      post.likedBy.remove(viewerId);
    }
    return _postDto(post, viewerId);
  }

  /// Bookmarks (saves) or un-bookmarks a post for [viewerId] and returns the
  /// updated post. Idempotent too: bookmarking again keeps the original time.
  Future<PostDto> setBookmarked(
    String viewerId,
    String postId, {
    required bool bookmarked,
  }) async {
    await _ready();
    final post = _post(postId);
    if (bookmarked) {
      post.bookmarks.putIfAbsent(viewerId, () => _clock.now().toUtc());
    } else {
      post.bookmarks.remove(viewerId);
    }
    return _postDto(post, viewerId);
  }

  // ---------------------------------------------------------------------------
  // Seeding

  Future<void> _ready() => _seeding ??= _seed();

  Future<void> _seed() async {
    final demo = await _seeds.loadAuthUser();
    final posts = await _seeds.loadPosts();
    final comments = await _seeds.loadComments();

    // The seed's dates are fixed (July 2026). Shift them all by the same
    // amount, so the newest record is a few minutes old whenever the app
    // launches and the feed always looks fresh. The gaps between records
    // stay as they are in the seed.
    final newest = [
      for (final post in posts) post.createdAt,
      for (final comment in comments) comment.createdAt,
    ].reduce((a, b) => a.isAfter(b) ? a : b);
    final launch = _clock.now().toUtc();
    final shift = launch.subtract(newestSeedAge).difference(newest);

    _signedInUserId = demo.id;
    _users[demo.id] = _profile(demo);
    for (final post in posts) {
      _users.putIfAbsent(post.author.id, () => _profile(post.author));
      _posts[post.id] = _ServerPost(
        id: post.id,
        authorId: post.author.id,
        content: post.content,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt.add(shift),
        seedLikes: post.likeCount,
      );
    }
    // The seed's `commentCount` is ignored: the count comes from the
    // comments themselves, so it can never disagree with them (the iOS seed
    // claims 18 comments on p1 and ships 3).
    for (final comment in comments) {
      _users.putIfAbsent(comment.author.id, () => _profile(comment.author));
      _commentCounts.update(
        comment.postId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers

  _ServerPost _post(String postId) =>
      _posts[postId] ?? (throw const NotFoundException());

  List<_ServerPost> _postsNewestFirst() =>
      _posts.values.toList()..sort(_ServerPost.newestFirst);

  /// A post as [viewerId] sees it. Counts are computed here, on every
  /// response, so they can never disagree with the data.
  PostDto _postDto(_ServerPost post, String viewerId) => PostDto(
    id: post.id,
    author: _users[post.authorId]!,
    content: post.content,
    imageUrl: post.imageUrl,
    createdAt: post.createdAt,
    likeCount: post.likeCount,
    commentCount: _commentCounts[post.id] ?? 0,
    isLiked: post.likedBy.contains(viewerId),
    bookmarkedAt: post.bookmarks[viewerId],
  );

  /// A public profile: the seed's demo user has an email, which never
  /// leaves the server.
  static UserDto _profile(UserDto user) => UserDto(
    id: user.id,
    name: user.name,
    avatarUrl: user.avatarUrl,
    bio: user.bio,
    followersCount: user.followersCount,
    followingCount: user.followingCount,
  );
}

/// The server's own record of a post. Likes and bookmarks are kept per user,
/// so every viewer gets their own `isLiked` and `bookmarkedAt`.
final class _ServerPost {
  _ServerPost({
    required this.id,
    required this.authorId,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.seedLikes,
  });

  final String id;
  final String authorId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  /// Likes from people outside this fake world: the seed's count.
  final int seedLikes;

  /// Ids of the users who like the post.
  final likedBy = <String>{};

  /// When each user bookmarked the post, by user id.
  final bookmarks = <String, DateTime>{};

  int get likeCount => seedLikes + likedBy.length;

  /// Newest first, ties broken by id (descending), the feed's order.
  static int newestFirst(_ServerPost a, _ServerPost b) {
    final byTime = b.createdAt.compareTo(a.createdAt);
    return byTime != 0 ? byTime : b.id.compareTo(a.id);
  }
}

/// A position in the feed: "just after this post". Encoded as
/// `<createdAt>|<id>`, which the client treats as an opaque string.
final class const _Cursor(final DateTime createdAt, final String id) {
  _Cursor.at(_ServerPost post) : this(post.createdAt, post.id);

  /// Throws a [FormatException] for anything this server didn't issue (a
  /// real API would answer 400 Bad Request).
  static _Cursor decode(String cursor) {
    final parts = cursor.split('|');
    if (parts.length != 2) throw FormatException('Invalid cursor', cursor);
    return _Cursor(DateTime.parse(parts.first), parts.last);
  }

  String encode() => '${createdAt.toIso8601String()}|$id';

  /// Whether [post] comes after this position in newest-first order.
  bool isNewerThan(_ServerPost post) =>
      post.createdAt.isBefore(createdAt) ||
      (post.createdAt.isAtSameMomentAs(createdAt) && post.id.compareTo(id) < 0);
}
