import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/profile_repository.dart';

/// Fetches a profile into the cache (`NotFoundException` if there's none).
class RefreshUserUseCase {
  const RefreshUserUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<Result<void>> call(String userId) => _profiles.refreshUser(userId);
}
