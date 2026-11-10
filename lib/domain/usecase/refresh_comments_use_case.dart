import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/comment_repository.dart';

/// Makes the cached comments on a post match the server's.
class RefreshCommentsUseCase {
  const RefreshCommentsUseCase(this._comments);

  final CommentRepository _comments;

  Future<Result<void>> call(String postId) => _comments.refreshComments(postId);
}
