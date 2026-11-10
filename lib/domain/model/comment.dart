import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';

/// A comment on a post, as the signed-in user sees it.
///
/// - [isMine] is worked out from the signed-in user when comments are read,
///   never stored.
/// - [isLiked] is the signed-in user's own like; [likeCount] everyone's.
@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String postId,
    required User author,
    required String text,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default(false) bool isLiked,
    @Default(false) bool isMine,
  }) = _Comment;
}
