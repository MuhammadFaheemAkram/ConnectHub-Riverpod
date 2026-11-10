import 'package:connect_hub_riverpod/core/database/app_database.dart';
import 'package:connect_hub_riverpod/core/database/daos/comments_dao.dart';
import 'package:connect_hub_riverpod/core/database/daos/posts_dao.dart';
import 'package:connect_hub_riverpod/core/database/tables/notifications_table.dart';

import 'backend.dart';

/// Row builders for the DAO tests: just enough to tell rows apart.

UserRow userRow(String id, {String? name}) => UserRow(
  id: id,
  name: name ?? 'User $id',
  bio: '',
  followersCount: 0,
  followingCount: 0,
);

/// A post by [authorId], [minutesAgo] minutes before [testNow].
CachedPost cachedPost(
  String id, {
  String authorId = 'u_ada',
  int minutesAgo = 0,
  int likeCount = 10,
  bool isLiked = false,
  DateTime? bookmarkedAt,
}) => (
  post: PostRow(
    id: id,
    authorId: authorId,
    content: 'Post $id',
    createdAt: testNow.subtract(Duration(minutes: minutesAgo)),
    likeCount: likeCount,
    commentCount: 0,
    isLiked: isLiked,
  ),
  author: userRow(authorId),
  bookmarkedAt: bookmarkedAt,
);

/// A comment on [postId] by [authorId], [minutesAgo] minutes before
/// [testNow].
CachedComment cachedComment(
  String id, {
  String postId = 'p1',
  String authorId = 'u_grace',
  int minutesAgo = 0,
  int likeCount = 0,
  bool isLiked = false,
}) => (
  comment: CommentRow(
    id: id,
    postId: postId,
    authorId: authorId,
    content: 'Comment $id',
    createdAt: testNow.subtract(Duration(minutes: minutesAgo)),
    likeCount: likeCount,
    isLiked: isLiked,
  ),
  author: userRow(authorId),
);

/// A notification, [minutesAgo] minutes before [testNow].
NotificationRow notificationRow(
  String id, {
  bool isRead = false,
  int minutesAgo = 0,
  NotificationRowKind kind = NotificationRowKind.like,
  String? postId,
  String? userId,
}) => NotificationRow(
  id: id,
  kind: kind,
  content: 'Notification $id',
  createdAt: testNow.subtract(Duration(minutes: minutesAgo)),
  isRead: isRead,
  postId: postId,
  userId: userId,
);
