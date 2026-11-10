import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/saved_posts_repository.dart';

/// Makes the cached saved posts match the server's.
class RefreshSavedPostsUseCase {
  const RefreshSavedPostsUseCase(this._saved);

  final SavedPostsRepository _saved;

  Future<Result<void>> call() => _saved.refreshSavedPosts();
}
