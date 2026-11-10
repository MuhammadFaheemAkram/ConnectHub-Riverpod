import 'package:connect_hub_riverpod/domain/model/comment.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_detail_state.freezed.dart';

/// What Post Detail shows once the post is there.
///
/// Loading, "couldn't load" and "no longer available" are the `AsyncValue`
/// around it: `AsyncLoading`, `AsyncError`, and `AsyncError` holding a
/// `NotFoundException`.
@freezed
abstract class PostDetailState with _$PostDetailState {
  const factory PostDetailState({
    required Post post,

    /// Every comment, oldest first.
    @Default(<Comment>[]) List<Comment> comments,

    /// A comment is on its way: Send shows progress.
    @Default(false) bool isSending,

    /// Goes up by one each time a comment is sent. The page clears the input
    /// and scrolls to the comment when it changes.
    @Default(0) int sentCount,

    /// A one-off SnackBar, consumed by `messageShown()`.
    String? message,
  }) = _PostDetailState;
}
