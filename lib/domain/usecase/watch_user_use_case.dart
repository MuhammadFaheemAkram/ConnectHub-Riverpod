import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:connect_hub_riverpod/domain/repository/profile_repository.dart';

/// One cached profile, live; `null` while it isn't cached.
class WatchUserUseCase {
  const WatchUserUseCase(this._profiles);

  final ProfileRepository _profiles;

  Stream<User?> call(String userId) => _profiles.watchUser(userId);
}
