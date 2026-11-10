import 'package:connect_hub_riverpod/core/database/app_database.dart';
import 'package:connect_hub_riverpod/core/database/daos/comments_dao.dart';
import 'package:connect_hub_riverpod/core/network/dto/comment_dto.dart';
import 'package:connect_hub_riverpod/data/mapper/user_mappers.dart';
import 'package:connect_hub_riverpod/domain/model/comment.dart';

extension CommentDtoMapper on CommentDto {
  /// The comment split into the rows it is cached as.
  CachedComment toCached() => (
    comment: CommentRow(
      id: id,
      postId: postId,
      authorId: author.id,
      content: text,
      createdAt: createdAt.toUtc(),
      likeCount: likeCount,
      isLiked: isLiked,
    ),
    author: author.toRow(),
  );
}

extension CachedCommentMapper on CachedComment {
  /// [signedInUserId] decides [Comment.isMine]: one identity drives it
  /// everywhere.
  Comment toDomain({required String signedInUserId}) => Comment(
    id: comment.id,
    postId: comment.postId,
    author: author.toDomain(),
    text: comment.content,
    createdAt: comment.createdAt,
    likeCount: comment.likeCount,
    isLiked: comment.isLiked,
    isMine: comment.authorId == signedInUserId,
  );
}
