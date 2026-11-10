import 'package:connect_hub_riverpod/core/network/dto/comment_dto.dart';

/// The comment endpoints, Retrofit-style. The server answers for the
/// signed-in user, so `isLiked` is theirs.
abstract interface class CommentApiService {
  /// `GET /posts/{postId}/comments`: oldest first.
  Future<List<CommentDto>> getComments(String postId);

  /// `POST /posts/{postId}/comments`: the new comment, by the signed-in user.
  Future<CommentDto> addComment(String postId, String text);

  /// `DELETE /comments/{commentId}`: only its author may delete it.
  Future<void> deleteComment(String commentId);

  /// `PUT` / `DELETE /comments/{commentId}/like`
  Future<CommentDto> setLiked(String commentId, {required bool liked});
}
