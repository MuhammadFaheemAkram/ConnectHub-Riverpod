import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/data_stack.dart';
import '../../helpers/database_rows.dart';

// Profiles, saved posts, Clear cache and the developer switch, on the real
// data stack.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack backend;

  setUp(() => backend = DataStack());

  Matcher isErr(Matcher exception) =>
      isA<Err<void>>().having((err) => err.exception, 'exception', exception);

  group('profiles', () {
    test('a profile and its posts are cached from the server', () async {
      final profiles = backend.container.read(profileRepositoryProvider);

      expect(await profiles.refreshUser('u_ada'), isA<Ok<void>>());
      expect(await profiles.refreshUserPosts('u_ada'), isA<Ok<void>>());

      expect((await profiles.watchUser('u_ada').first)?.name, 'Ada Lovelace');
      final posts = await profiles.watchUserPosts('u_ada').first;
      expect(posts.map((post) => post.id), ['p1', 'p6', 'p11']);
    });

    test('an unknown user is not found, and their cached posts go', () async {
      final profiles = backend.container.read(profileRepositoryProvider);
      await backend.database.postsDao.upsertPosts([
        cachedPost('p_x', authorId: 'u_gone'),
      ]);

      expect(
        await profiles.refreshUser('u_gone'),
        isErr(isA<NotFoundException>()),
      );
      expect(
        await profiles.refreshUserPosts('u_gone'),
        isErr(isA<NotFoundException>()),
      );
      expect(await profiles.watchUserPosts('u_gone').first, isEmpty);
    });
  });

  group('saved posts', () {
    test("mirror the server's, and a save anywhere shows at once", () async {
      final saved = backend.container.read(savedPostsRepositoryProvider);
      await backend.feed.refresh();

      await backend.posts.setBookmarked('p2', bookmarked: true);
      expect((await saved.watchSavedPosts().first).map((p) => p.id), ['p2']);

      await backend.server.setBookmarked('u_demo', 'p2', bookmarked: false);
      await backend.server.setBookmarked('u_demo', 'p9', bookmarked: true);
      expect(await saved.refreshSavedPosts(), isA<Ok<void>>());

      expect((await saved.watchSavedPosts().first).map((p) => p.id), ['p9']);
    });
  });

  test('Clear cache keeps the saved posts', () async {
    await backend.feed.refresh();
    await backend.posts.setBookmarked('p2', bookmarked: true);

    await backend.container.read(cacheRepositoryProvider).clearCache();

    expect(await backend.feedIds(), isEmpty);
    final saved = backend.container.read(savedPostsRepositoryProvider);
    expect((await saved.watchSavedPosts().first).map((p) => p.id), ['p2']);
  });

  test('Clear cache keeps me, and forgets the others', () async {
    final profiles = backend.container.read(profileRepositoryProvider);
    await profiles.refreshUser('u_demo');
    await profiles.refreshUser('u_ada');

    await backend.container.read(cacheRepositoryProvider).clearCache();

    expect((await profiles.watchUser('u_demo').first)?.name, 'Demo User');
    expect(await profiles.watchUser('u_ada').first, isNull);
  });

  test('the developer switch fails every request, and resets', () async {
    final tools = backend.container.read(demoToolsRepositoryProvider);

    tools.setFailsRequests(fail: true);
    expect(tools.failsRequests, isTrue);
    expect(backend.network.failRequests, isTrue);

    tools.setFailsRequests(fail: false);
    expect(await backend.feed.refresh(), isA<Ok<bool>>());
  });
}
