import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/comment_repository.dart';

/// Deletes one of the signed-in user's comments (optimistic, rolled back on
/// failure).
class DeleteCommentUseCase {
  const DeleteCommentUseCase(this._comments);

  final CommentRepository _comments;

  Future<Result<void>> call(String commentId) =>
      _comments.deleteComment(commentId);
}
