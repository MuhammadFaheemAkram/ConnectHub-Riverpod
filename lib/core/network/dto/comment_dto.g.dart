// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'comment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentDto _$CommentDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CommentDto', json, ($checkedConvert) {
  final val = CommentDto(
    id: $checkedConvert('id', (v) => v as String),
    postId: $checkedConvert('postId', (v) => v as String),
    author: $checkedConvert(
      'author',
      (v) => UserDto.fromJson(v as Map<String, dynamic>),
    ),
    text: $checkedConvert('text', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    likeCount: $checkedConvert('likeCount', (v) => (v as num?)?.toInt() ?? 0),
    isLiked: $checkedConvert('isLiked', (v) => v as bool? ?? false),
  );
  return val;
});
