import 'package:connect_hub_riverpod/core/network/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_dto.g.dart';

/// A comment on a post, as the API describes it to one viewer: [isLiked] is
/// their own like. The seed file has the same shape, without the likes.
@JsonSerializable(createToJson: false, checked: true)
class CommentDto {
  const CommentDto({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);

  final String id;
  final String postId;
  final UserDto author;
  final String text;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;
}
