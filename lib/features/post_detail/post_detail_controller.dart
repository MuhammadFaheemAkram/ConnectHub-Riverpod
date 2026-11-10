import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/first_value.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/di/use_case_providers.dart';
import 'package:connect_hub_riverpod/domain/model/comment.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/features/post_detail/post_detail_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_detail_controller.g.dart';

/// One cached post, live: a **family** keyed by the post id. Each id gets its
/// own provider (and drift query), disposed when nothing watches it.
@riverpod
Stream<Post?> cachedPost(Ref ref, String postId) =>
    ref.watch(watchPostUseCaseProvider)(postId);

/// The cached comments on one post, live, oldest first.
@riverpod
Stream<List<Comment>> postComments(Ref ref, String postId) =>
    ref.watch(watchCommentsUseCaseProvider)(postId);

/// Drives Post Detail: one post, its comments, the comment input.
///
/// - **A family:** `postDetailControllerProvider('p1')` and
///   `postDetailControllerProvider('p2')` are separate controllers with
///   separate state. ConnectHub-Flutter passed the id through get_it's
///   `@factoryParam`; here it is the provider's argument, and the generated
///   notifier exposes it as [postId].
/// - **Auto-dispose:** leaving the page frees the controller (and its two
///   drift queries); opening the post again starts from the cache.
/// - Like the Feed, it shows the cache at once and refreshes behind it.
@riverpod
class PostDetailController extends _$PostDetailController {
  static const refreshFailedMessage =
      "Couldn't refresh. Showing the saved post.";
  static const commentsFailedMessage = "Couldn't load the latest comments.";
  static const sendFailedMessage =
      "Couldn't send your comment. Please try again.";
  static const deleteFailedMessage =
      "Couldn't delete your comment. Please try again.";
  static const likeFailedMessage =
      "Couldn't update the like. Please try again.";
  static const saveFailedMessage =
      "Couldn't update the save. Please try again.";

  @override
  Future<PostDetailState> build(String postId) async {
    // Live updates, without re-running this build (see FeedController). A
    // like on the feed, a new comment: both arrive through drift.
    ref
      ..watch(cacheEpochProvider)
      ..listen(cachedPostProvider(postId), (_, next) {
        if (next case AsyncData(value: final post?)) {
          _update((detail) => detail.copyWith(post: post));
        }
      })
      ..listen(postCommentsProvider(postId), (_, next) {
        if (next case AsyncData(value: final comments)) {
          _update((detail) => detail.copyWith(comments: comments));
        }
      });

    final cached = await _readPost();
    if (cached != null) {
      // On the next turn of the event loop, once this state is in place.
      unawaited(Future(refresh));
      return PostDetailState(post: cached, comments: await _readComments());
    }

    // Not cached (a deep link, or a post from a later phase's search): the
    // post and its comments load side by side, and the screen waits.
    final (post, comments) = await _refreshBoth();
    if (post case Err(:final exception)) throw exception;
    final fresh = await _readPost();
    if (fresh == null) throw const NotFoundException();
    return PostDetailState(
      post: fresh,
      comments: await _readComments(),
      message: comments is Err<void> ? commentsFailedMessage : null,
    );
  }

  /// Pull to refresh, and the refresh behind the cache.
  Future<void> refresh() async {
    if (!ref.mounted) return;
    final (post, comments) = await _refreshBoth();
    if (!ref.mounted) return;
    switch (post) {
      case Err(exception: NotFoundException() && final exception):
        // The server no longer has it, and the repository has removed the
        // cached copy: "This post is no longer available."
        state = AsyncError(exception, StackTrace.current);
      case Err():
        _update((detail) => detail.copyWith(message: refreshFailedMessage));
      case Ok():
        final fresh = await _readPost();
        final freshComments = await _readComments();
        if (!ref.mounted || fresh == null) return;
        _update(
          (detail) => detail.copyWith(
            post: fresh,
            comments: freshComments,
            message: comments is Err<void>
                ? commentsFailedMessage
                : detail.message,
          ),
        );
    }
  }

  /// Sends a comment. On success the count goes up ([PostDetailState
  /// .sentCount]: the page clears the input); on failure the text stays and
  /// a SnackBar says why.
  Future<void> sendComment(String text) async {
    final detail = state.value;
    if (detail == null || detail.isSending || text.trim().isEmpty) return;
    _update((detail) => detail.copyWith(isSending: true));
    final result = await ref.read(addCommentUseCaseProvider)(postId, text);
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        // List the new comment before the input clears (drift announces it
        // a moment later).
        final comments = await _readComments();
        if (!ref.mounted) return;
        _update(
          (detail) => detail.copyWith(
            comments: comments,
            isSending: false,
            sentCount: detail.sentCount + 1,
          ),
        );
      case Err():
        _update(
          (detail) =>
              detail.copyWith(isSending: false, message: sendFailedMessage),
        );
    }
  }

  Future<void> toggleLike(Post post) => _report(
    ref.read(likePostUseCaseProvider)(post.id, liked: !post.isLiked),
    likeFailedMessage,
  );

  Future<void> toggleSave(Post post) => _report(
    ref.read(savePostUseCaseProvider)(post.id, saved: !post.isBookmarked),
    saveFailedMessage,
  );

  Future<void> toggleCommentLike(Comment comment) => _report(
    ref.read(likeCommentUseCaseProvider)(comment.id, liked: !comment.isLiked),
    likeFailedMessage,
  );

  /// Optimistic in the repository: the comment goes at once, and comes back
  /// if the server refuses.
  Future<void> deleteComment(Comment comment) => _report(
    ref.read(deleteCommentUseCaseProvider)(comment.id),
    deleteFailedMessage,
  );

  void messageShown() => _update((detail) => detail.copyWith(message: null));

  /// Waits for [action] and, if it failed, shows [message].
  Future<void> _report(Future<Result<void>> action, String message) async {
    final result = await action;
    if (!ref.mounted) return;
    if (result is Err<void>) {
      _update((detail) => detail.copyWith(message: message));
    }
  }

  Future<(Result<void>, Result<void>)> _refreshBoth() => (
    ref.read(refreshPostUseCaseProvider)(postId),
    ref.read(refreshCommentsUseCaseProvider)(postId),
  ).wait;

  Future<Post?> _readPost() =>
      ref.read(watchPostUseCaseProvider)(postId).firstValue;

  Future<List<Comment>> _readComments() =>
      ref.read(watchCommentsUseCaseProvider)(postId).firstValue;

  /// Changes the state, if it has a value, and not while rebuilding (after
  /// Clear cache): the emptied cache must not replace what's on screen with
  /// "nothing" before the reload.
  void _update(PostDetailState Function(PostDetailState detail) change) {
    final detail = state.value;
    if (detail != null && !state.isLoading) state = AsyncData(change(detail));
  }
}
