import 'package:connect_hub_riverpod/domain/model/comment.dart';
import 'package:connect_hub_riverpod/domain/repository/comment_repository.dart';

/// A post's cached comments as a stream, oldest first.
class WatchCommentsUseCase {
  const WatchCommentsUseCase(this._comments);

  final CommentRepository _comments;

  Stream<List<Comment>> call(String postId) => _comments.watchComments(postId);
}
