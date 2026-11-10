import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/core/database/daos/comments_dao.dart';
import 'package:connect_hub_riverpod/core/database/daos/posts_dao.dart';
import 'package:connect_hub_riverpod/core/network/api/comment_api_service.dart';
import 'package:connect_hub_riverpod/data/mapper/comment_mappers.dart';
import 'package:connect_hub_riverpod/data/repository/api_guard.dart';
import 'package:connect_hub_riverpod/domain/model/comment.dart';
import 'package:connect_hub_riverpod/domain/repository/comment_repository.dart';
import 'package:connect_hub_riverpod/domain/repository/post_repository.dart';

/// A post's comments: rendered from drift, refreshed from the API; a delete
/// and a like are optimistic, a new comment waits for the server.
///
/// It holds state (the likes in flight), so its provider is `keepAlive`.
class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(
    this._api,
    this._comments,
    this._cachedPosts,
    this._posts, {
    required String signedInUserId,
  }) : _me = signedInUserId;

  final CommentApiService _api;
  final CommentsDao _comments;
  final PostsDao _cachedPosts;
  final PostRepository _posts;
  final String _me;

  /// The comment likes in flight, by comment id.
  final _likesInFlight = <String>{};

  @override
  Stream<List<Comment>> watchComments(String postId) => _comments
      .watchComments(postId)
      .map(
        (entries) => [
          for (final entry in entries) entry.toDomain(signedInUserId: _me),
        ],
      );

  @override
  Future<Result<void>> refreshComments(String postId) async {
    final result = await guardApiCall(() => _api.getComments(postId));
    switch (result) {
      case Ok(value: final comments):
        final entries = [for (final comment in comments) comment.toCached()];
        // A comment row needs its post (a foreign key), and a deep link can
        // open a post that isn't cached yet. Fetch the post first then.
        if (!await _cachedPosts.isCached(postId)) {
          final post = await _posts.refreshPost(postId);
          if (post case Err(:final exception)) return Err(exception);
        }
        await _comments.replaceComments(postId, entries);
        return const Ok(null);
      case Err(:final exception):
        // No post, no comments: the cached copy goes too.
        if (exception is NotFoundException) {
          await _cachedPosts.deletePost(postId);
        }
        return Err(exception);
    }
  }

  /// Not optimistic: a comment is cached once the server has accepted it.
  /// Meanwhile Send shows progress, and on failure the text stays in the
  /// field, ready to send again.
  @override
  Future<Result<void>> addComment(String postId, String text) async {
    final result = await guardApiCall(() => _api.addComment(postId, text));
    switch (result) {
      case Ok(value: final comment):
        await _comments.addComment(comment.toCached());
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }

  /// Optimistic: the comment disappears (and the count drops) at once. If
  /// the server refuses, it comes back where it was.
  @override
  Future<Result<void>> deleteComment(String commentId) async {
    final removed = await _comments.removeComment(commentId);
    final result = await guardApiCall(() => _api.deleteComment(commentId));
    if (result case Err(:final exception)) {
      if (removed != null) await _comments.restoreComment(removed);
      return Err(exception);
    }
    return const Ok(null);
  }

  /// Optimistic, like a post's like, and one request per comment at a time
  /// (a second tap meanwhile is ignored), so a rollback restores a state the
  /// server confirmed.
  @override
  Future<Result<void>> setLiked(String commentId, {required bool liked}) async {
    if (!_likesInFlight.add(commentId)) return const Ok(null);
    try {
      final before = await _comments.applyLike(commentId, liked: liked);
      final result = await guardApiCall(
        () => _api.setLiked(commentId, liked: liked),
      );
      switch (result) {
        case Ok(value: final comment):
          await _comments.writeLike(commentId, (
            isLiked: comment.isLiked,
            likeCount: comment.likeCount,
          ));
          return const Ok(null);
        case Err(:final exception):
          if (before != null) await _comments.writeLike(commentId, before);
          return Err(exception);
      }
    } finally {
      _likesInFlight.remove(commentId);
    }
  }
}
