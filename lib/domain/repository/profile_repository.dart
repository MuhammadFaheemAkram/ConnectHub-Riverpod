import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';

/// Profiles: read from the cache and refreshed from the server.
abstract interface class ProfileRepository {
  /// The cached profile: now, then after every change; `null` while it
  /// isn't cached.
  Stream<User?> watchUser(String userId);

  /// Fetches the profile into the cache. Answers `NotFoundException` when
  /// the server has no such user.
  Future<Result<void>> refreshUser(String userId);

  /// The user's cached posts, newest first: now, then after every change.
  Stream<List<Post>> watchUserPosts(String userId);

  /// Makes the cache match the server's list of the user's posts.
  Future<Result<void>> refreshUserPosts(String userId);
}
