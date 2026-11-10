import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';

/// The signed-in user's saved posts (bookmarks on the server), cached in
/// drift so Profile → Saved works offline.
///
/// Saving and unsaving go through `PostRepository.setBookmarked`, the same
/// optimistic write every screen uses.
abstract interface class SavedPostsRepository {
  /// The cached saved posts, the most recently saved first: now, then after
  /// every change.
  Stream<List<Post>> watchSavedPosts();

  /// Makes the cache match the server's saved posts.
  Future<Result<void>> refreshSavedPosts();
}
