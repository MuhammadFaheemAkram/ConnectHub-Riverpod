import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/profile_repository.dart';

/// Makes a user's cached posts match the server's.
class RefreshUserPostsUseCase {
  const RefreshUserPostsUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<Result<void>> call(String userId) =>
      _profiles.refreshUserPosts(userId);
}
