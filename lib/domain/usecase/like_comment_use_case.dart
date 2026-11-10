import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/comment_repository.dart';

/// Likes or unlikes a comment (optimistic, rolled back on failure).
class LikeCommentUseCase {
  const LikeCommentUseCase(this._comments);

  final CommentRepository _comments;

  Future<Result<void>> call(String commentId, {required bool liked}) =>
      _comments.setLiked(commentId, liked: liked);
}
