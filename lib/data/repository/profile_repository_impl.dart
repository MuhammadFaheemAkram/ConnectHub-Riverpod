import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/core/database/daos/posts_dao.dart';
import 'package:connect_hub_riverpod/core/database/daos/users_dao.dart';
import 'package:connect_hub_riverpod/core/network/api/user_api_service.dart';
import 'package:connect_hub_riverpod/data/mapper/post_mappers.dart';
import 'package:connect_hub_riverpod/data/mapper/user_mappers.dart';
import 'package:connect_hub_riverpod/data/repository/api_guard.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:connect_hub_riverpod/domain/repository/profile_repository.dart';

/// Profiles, read from the cache and refreshed from the server.
///
/// Authors are stored once, in `users`, and every post and comment JOINs
/// them: a refreshed profile renames its author everywhere at once.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api, this._users, this._posts);

  final UserApiService _api;
  final UsersDao _users;
  final PostsDao _posts;

  @override
  Stream<User?> watchUser(String userId) =>
      _users.watchUser(userId).map((row) => row?.toDomain());

  @override
  Future<Result<void>> refreshUser(String userId) async {
    final result = await guardApiCall(() => _api.getUser(userId));
    switch (result) {
      case Ok(value: final user):
        await _users.upsertUser(user.toRow());
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }

  @override
  Stream<List<Post>> watchUserPosts(String userId) => _posts
      .watchPostsByAuthor(userId)
      .map((entries) => [for (final entry in entries) entry.toDomain()]);

  @override
  Future<Result<void>> refreshUserPosts(String userId) async {
    final result = await guardApiCall(() => _api.getUserPosts(userId));
    switch (result) {
      case Ok(value: final posts):
        await _posts.replacePostsByAuthor(userId, [
          for (final post in posts) post.toCached(),
        ]);
        return const Ok(null);
      case Err(:final exception):
        // No such user, so no such posts: the cached ones go too.
        if (exception is NotFoundException) {
          await _posts.replacePostsByAuthor(userId, const []);
        }
        return Err(exception);
    }
  }
}
