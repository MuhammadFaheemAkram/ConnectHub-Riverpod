import 'package:connect_hub_riverpod/core/database/app_database.dart';
import 'package:connect_hub_riverpod/core/database/tables/bookmarks_table.dart';
import 'package:connect_hub_riverpod/core/database/tables/comments_table.dart';
import 'package:connect_hub_riverpod/core/database/tables/feed_items_table.dart';
import 'package:connect_hub_riverpod/core/database/tables/notifications_table.dart';
import 'package:connect_hub_riverpod/core/database/tables/posts_table.dart';
import 'package:connect_hub_riverpod/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'cache_dao.g.dart';

/// Whole-cache operations: Settings → Clear cache.
@DriftAccessor(
  tables: [Comments, FeedItems, Bookmarks, Posts, Users, Notifications],
)
class CacheDao extends DatabaseAccessor<AppDatabase> with _$CacheDaoMixin {
  CacheDao(super.attachedDatabase);

  /// Deletes the cached copy of what the server owns (the feed, posts,
  /// comments, profiles, notifications), which the screens fetch again. It
  /// keeps, in one transaction:
  /// - saved posts and their authors, so Profile → Saved works offline;
  /// - the signed-in user ([keepUserId]);
  /// - the recent searches, which the client owns (and the settings, which
  ///   aren't in drift at all).
  ///
  /// Children before parents: comments reference users without a cascade.
  Future<void> clearServerData({required String keepUserId}) {
    return transaction(() async {
      await delete(feedItems).go();
      await delete(comments).go();
      await delete(notifications).go();
      final saved = selectOnly(bookmarks)..addColumns([bookmarks.postId]);
      await (delete(posts)..where((post) => post.id.isNotInQuery(saved))).go();
      final authors = selectOnly(posts)..addColumns([posts.authorId]);
      await (delete(users)..where(
            (user) =>
                user.id.equals(keepUserId).not() &
                user.id.isNotInQuery(authors),
          ))
          .go();
    });
  }
}
