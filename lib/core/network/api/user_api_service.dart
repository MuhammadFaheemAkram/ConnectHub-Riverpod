import 'package:connect_hub_riverpod/core/network/dto/post_dto.dart';
import 'package:connect_hub_riverpod/core/network/dto/user_dto.dart';

/// The profile endpoints, Retrofit-style. `GET /users/{id}` serves the
/// signed-in user's own profile too.
abstract interface class UserApiService {
  /// `GET /users/{userId}`
  Future<UserDto> getUser(String userId);

  /// `GET /users/{userId}/posts`: every post by the user, newest first.
  Future<List<PostDto>> getUserPosts(String userId);
}
