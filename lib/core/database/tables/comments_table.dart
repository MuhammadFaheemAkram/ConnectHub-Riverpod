import 'package:connect_hub_riverpod/core/database/tables/posts_table.dart';
import 'package:connect_hub_riverpod/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

/// Cached comments (schema v2, Phase 3).
///
/// - `ON DELETE CASCADE` on the post: a comment goes when its post leaves the
///   cache. Another reason posts are only ever upserted, never replaced.
/// - The author is a reference, JOINed on every read, so a renamed author is
///   renamed on all their comments at once.
/// - Whether a comment is *mine* isn't stored: it is worked out from the
///   signed-in user when the comments are read.
/// - The like is stored like a post's: everyone's count, and whether the
///   signed-in user is one of them.
@DataClassName('CommentRow')
class Comments extends Table {
  TextColumn get id => text()();

  TextColumn get postId =>
      text().references(Posts, #id, onDelete: KeyAction.cascade)();

  TextColumn get authorId => text().references(Users, #id)();

  /// The comment's text. (A column named `text` would hide drift's `text()`
  /// column builder inside this class.)
  TextColumn get content => text()();

  /// UTC, stored as ISO-8601 text (see `build.yaml`).
  DateTimeColumn get createdAt => dateTime()();

  IntColumn get likeCount => integer().withDefault(const Constant(0))();

  BoolColumn get isLiked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
