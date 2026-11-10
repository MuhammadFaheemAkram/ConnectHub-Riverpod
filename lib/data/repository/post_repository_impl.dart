import 'package:clock/clock.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/core/database/daos/posts_dao.dart';
import 'package:connect_hub_riverpod/core/network/api/feed_api_service.dart';
import 'package:connect_hub_riverpod/data/repository/api_guard.dart';
import 'package:connect_hub_riverpod/domain/repository/post_repository.dart';

/// One post, liked or saved optimistically.
///
/// The optimistic update lives here, not in a notifier, because it is a data
/// concern: write drift first (every screen showing the post updates through
/// its own stream), call the API, then either take the server's answer or
/// roll back and return `Err`. A notifier only reports the error. That is the
/// same split as ConnectHub-Flutter, where a Cubit only reported it.
///
/// It holds state (the requests in flight), so its provider is `keepAlive`.
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._api, this._posts, this._clock);

  final FeedApiService _api;
  final PostsDao _posts;
  final Clock _clock;

  /// The requests in flight, as `like:<postId>` and `bookmark:<postId>`.
  final _inFlight = <String>{};

  @override
  Future<Result<void>> setLiked(String postId, {required bool liked}) {
    return _oneAtATime('like:$postId', () async {
      // 1. The heart and the count change before the server answers.
      final before = await _posts.applyLike(postId, liked: liked);
      final result = await guardApiCall(
        () => _api.setLiked(postId, liked: liked),
      );
      switch (result) {
        case Ok(value: final post):
          // 2a. Take the server's numbers: its count includes everyone
          // else's likes too.
          await _posts.writeLike(postId, (
            isLiked: post.isLiked,
            likeCount: post.likeCount,
          ));
          return const Ok(null);
        case Err(:final exception):
          // 2b. Put back what the user saw before the tap.
          if (before != null) await _posts.writeLike(postId, before);
          return Err(exception);
      }
    });
  }

  @override
  Future<Result<void>> setBookmarked(
    String postId, {
    required bool bookmarked,
  }) {
    return _oneAtATime('bookmark:$postId', () async {
      final before = await _posts.applyBookmark(
        postId,
        at: bookmarked ? _clock.now().toUtc() : null,
      );
      final result = await guardApiCall(
        () => _api.setBookmarked(postId, bookmarked: bookmarked),
      );
      switch (result) {
        case Ok(value: final post):
          // The server's time replaces the local guess.
          await _posts.writeBookmark(postId, at: post.bookmarkedAt?.toUtc());
          return const Ok(null);
        case Err(:final exception):
          await _posts.writeBookmark(postId, at: before);
          return Err(exception);
      }
    });
  }

  /// Runs [action] unless the same action on the same post is still in
  /// flight; a second tap meanwhile is ignored.
  ///
  /// That keeps every rollback honest: the state it restores is one the
  /// server had confirmed, never another tap's unconfirmed guess.
  Future<Result<void>> _oneAtATime(
    String key,
    Future<Result<void>> Function() action,
  ) async {
    if (!_inFlight.add(key)) return const Ok(null);
    try {
      return await action();
    } finally {
      _inFlight.remove(key);
    }
  }
}
