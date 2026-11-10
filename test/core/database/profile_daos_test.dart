import 'package:connect_hub_riverpod/core/database/app_database.dart';
import 'package:connect_hub_riverpod/core/database/daos/posts_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

// The DAOs behind profiles: one user, an author's posts, the saved posts.
void main() {
  late AppDatabase database;

  setUp(() => database = newTestDatabase());
  tearDown(() => database.close());

  List<String> ids(List<CachedPost> posts) => [
    for (final entry in posts) entry.post.id,
  ];

  test('a profile is cached, renamed in place, and followed live', () async {
    expect(await database.usersDao.watchUser('u_ada').first, isNull);

    await database.usersDao.upsertUser(userRow('u_ada', name: 'Ada'));
    await database.usersDao.upsertUser(userRow('u_ada', name: 'Countess'));

    expect(
      (await database.usersDao.watchUser('u_ada').first)?.name,
      'Countess',
    );
  });

  test("an author's posts, newest first; a refresh mirrors the server and "
      "touches nobody else's", () async {
    final posts = database.postsDao;
    await posts.upsertPosts([
      cachedPost('p1', minutesAgo: 30),
      cachedPost('p_gone', minutesAgo: 10),
      cachedPost('p3', authorId: 'u_grace'),
    ]);

    await posts.replacePostsByAuthor('u_ada', [
      cachedPost('p2', minutesAgo: 5),
      cachedPost('p1', minutesAgo: 30),
    ]);

    expect(ids(await posts.watchPostsByAuthor('u_ada').first), ['p2', 'p1']);
    expect(await posts.isCached('p3'), isTrue);
  });

  test('saved posts, the most recently saved first; a refresh removes the '
      'saves the server dropped, not the posts', () async {
    final saved = database.bookmarksDao;
    await saved.replaceBookmarks([
      cachedPost('p1', bookmarkedAt: testNow),
      cachedPost('p2', bookmarkedAt: testNow.add(const Duration(minutes: 1))),
    ]);
    expect(ids(await saved.watchBookmarks().first), ['p2', 'p1']);

    await saved.replaceBookmarks([cachedPost('p2', bookmarkedAt: testNow)]);

    expect(ids(await saved.watchBookmarks().first), ['p2']);
    expect(await database.postsDao.isCached('p1'), isTrue);
  });
}
