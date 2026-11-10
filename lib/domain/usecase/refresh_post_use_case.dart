import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/post_repository.dart';

/// Fetches one post into the cache (`NotFoundException` if it's gone).
class RefreshPostUseCase {
  const RefreshPostUseCase(this._posts);

  final PostRepository _posts;

  Future<Result<void>> call(String postId) => _posts.refreshPost(postId);
}
