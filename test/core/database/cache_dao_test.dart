import 'package:connect_hub_riverpod/core/database/app_database.dart';
import 'package:drift/drift.dart' show Table, TableInfo;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = newTestDatabase());
  tearDown(() => database.close());

  Future<List<String>> ids<T extends Table, R>(
    TableInfo<T, R> table,
    String Function(R row) id,
  ) async => [for (final row in await database.select(table).get()) id(row)];

  test('Clear cache deletes the server data, and keeps saved posts with '
      'their authors, me, and the recent searches', () async {
    await database.feedDao.replaceFeed([
      cachedPost('p1'),
      cachedPost('p2', authorId: 'u_grace', bookmarkedAt: testNow),
    ]);
    await database.usersDao.upsertUser(userRow('u_demo'));
    await database.usersDao.upsertUser(userRow('u_alan'));
    await database.commentsDao.addComment(cachedComment('c1', postId: 'p2'));
    await database.notificationsDao.replaceNotifications([
      notificationRow('n1'),
    ]);
    await database.searchDao.saveRecentSearch('ada', at: testNow);

    await database.cacheDao.clearServerData(keepUserId: 'u_demo');

    expect(
      await ids(database.feedItems, (FeedItemRow row) => row.postId),
      isEmpty,
    );
    expect(await ids(database.posts, (PostRow row) => row.id), ['p2']);
    expect(await ids(database.bookmarks, (BookmarkRow row) => row.postId), [
      'p2',
    ]);
    expect(
      await ids(database.users, (UserRow row) => row.id),
      unorderedEquals(['u_grace', 'u_demo']),
    );
    expect(await ids(database.comments, (CommentRow row) => row.id), isEmpty);
    expect(
      await ids(database.notifications, (NotificationRow row) => row.id),
      isEmpty,
    );
    expect(
      await ids(
        database.recentSearches,
        (RecentSearchRow row) => row.displayText,
      ),
      ['ada'],
    );
  });
}
