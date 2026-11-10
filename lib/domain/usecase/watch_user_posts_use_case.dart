import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/repository/profile_repository.dart';

/// A user's cached posts, newest first, live.
class WatchUserPostsUseCase {
  const WatchUserPostsUseCase(this._profiles);

  final ProfileRepository _profiles;

  Stream<List<Post>> call(String userId) => _profiles.watchUserPosts(userId);
}
