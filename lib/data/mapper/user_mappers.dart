import 'package:connect_hub_riverpod/core/database/app_database.dart';
import 'package:connect_hub_riverpod/core/network/dto/user_dto.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';

extension UserDtoMapper on UserDto {
  /// The row cached for this user. An email, if one came, is never cached.
  UserRow toRow() => UserRow(
    id: id,
    name: name,
    avatarUrl: avatarUrl,
    bio: bio,
    followersCount: followersCount,
    followingCount: followingCount,
  );
}

extension UserRowMapper on UserRow {
  User toDomain() => User(
    id: id,
    name: name,
    avatarUrl: avatarUrl,
    bio: bio,
    followersCount: followersCount,
    followingCount: followingCount,
  );
}
