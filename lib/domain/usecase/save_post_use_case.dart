import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/post_repository.dart';

/// Saves or unsaves a post (optimistic, rolled back on failure). Saved posts
/// are the server's bookmarks; Profile → Saved lists them (Phase 5).
class SavePostUseCase {
  const SavePostUseCase(this._posts);

  final PostRepository _posts;

  Future<Result<void>> call(String postId, {required bool saved}) =>
      _posts.setBookmarked(postId, bookmarked: saved);
}
