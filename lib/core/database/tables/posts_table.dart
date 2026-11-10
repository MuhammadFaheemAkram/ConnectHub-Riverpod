import 'package:connect_hub_riverpod/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

/// Cached posts, from wherever they were loaded: the feed now; post details,
/// search, profiles and saved posts later.
///
/// Being in this table doesn't put a post in the feed. The feed is its own
/// list ([FeedItems]), so a post cached by a search never leaks into it.
@DataClassName('PostRow')
class Posts extends Table {
  TextColumn get id => text()();

  TextColumn get authorId => text().references(Users, #id)();

  TextColumn get content => text()();

  TextColumn get imageUrl => text().nullable()();

  /// UTC, stored as ISO-8601 text (see `build.yaml`).
  DateTimeColumn get createdAt => dateTime()();

  IntColumn get likeCount => integer()();

  IntColumn get commentCount => integer()();

  /// Whether the signed-in user likes the post. The cache only ever holds one
  /// user's data: the demo user is the only one.
  BoolColumn get isLiked => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
