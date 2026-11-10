import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/comment_repository.dart';

/// Sends a comment, trimmed.
class AddCommentUseCase {
  const AddCommentUseCase(this._comments);

  final CommentRepository _comments;

  Future<Result<void>> call(String postId, String text) =>
      _comments.addComment(postId, text.trim());
}
