import 'package:connect_hub_riverpod/core/common/result.dart';

/// One post: liking and saving it. Phase 3 adds reading one post and
/// creating posts.
///
/// Likes and saves are optimistic: the cached post changes at once, every
/// screen showing it updates through its own drift stream, and if the server
/// refuses, the change is rolled back and the result is an `Err`.
abstract interface class PostRepository {
  Future<Result<void>> setLiked(String postId, {required bool liked});

  /// Saves (bookmarks) or unsaves a post for the signed-in user.
  Future<Result<void>> setBookmarked(String postId, {required bool bookmarked});
}
