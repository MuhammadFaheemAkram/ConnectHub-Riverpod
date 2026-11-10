import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/post_repository.dart';

/// Likes or unlikes a post (optimistic, rolled back on failure).
class LikePostUseCase {
  const LikePostUseCase(this._posts);

  final PostRepository _posts;

  Future<Result<void>> call(String postId, {required bool liked}) =>
      _posts.setLiked(postId, liked: liked);
}
