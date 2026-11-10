import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/repository/post_repository.dart';

/// One cached post as a stream; `null` while it isn't cached.
class WatchPostUseCase {
  const WatchPostUseCase(this._posts);

  final PostRepository _posts;

  Stream<Post?> call(String postId) => _posts.watchPost(postId);
}
