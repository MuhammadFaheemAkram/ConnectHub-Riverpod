import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/repository/saved_posts_repository.dart';

/// The saved posts, the most recently saved first, live.
class WatchSavedPostsUseCase {
  const WatchSavedPostsUseCase(this._saved);

  final SavedPostsRepository _saved;

  Stream<List<Post>> call() => _saved.watchSavedPosts();
}
