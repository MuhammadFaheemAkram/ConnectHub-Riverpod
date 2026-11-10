import 'package:connect_hub_riverpod/features/notifications/notifications_controller.dart';
import 'package:connect_hub_riverpod/features/post_detail/post_detail_controller.dart';
import 'package:connect_hub_riverpod/features/profile/profile_controller.dart';
import 'package:connect_hub_riverpod/features/search/search_controller.dart';
import 'package:connect_hub_riverpod/features/search/search_state.dart';
import 'package:connect_hub_riverpod/features/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';

// Clear cache on the real stack, seen from each screen that shows server
// data: it reloads (it watches the cache epoch), and while it does, the
// emptied tables never reach the screen. Every state is recorded.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = testContainer();
    container.listen(settingsToolsProvider, (_, _) {});
  });

  Future<void> clearCache() =>
      container.read(settingsToolsProvider.notifier).clearCache();

  /// Records [provider]'s states from now on, each described by [describe]
  /// once it has data.
  List<String> record<T>(
    ProviderListenable<AsyncValue<T>> provider,
    String Function(T value) describe,
  ) {
    final states = <String>[];
    container.listen(
      provider,
      (_, next) => states.add(switch (next) {
        AsyncValue(isLoading: true) => 'loading',
        AsyncData(:final value) => describe(value),
        _ => 'error',
      }),
    );
    return states;
  }

  test('notifications reload, and never show "none" meanwhile', () async {
    final states = record(
      notificationsControllerProvider,
      (state) => '${state.notifications.length} notifications',
    );
    await container.read(notificationsControllerProvider.future);
    await pumpEventQueue();
    states.clear();

    await clearCache();
    await container.read(notificationsControllerProvider.future);
    await pumpEventQueue();

    expect(states, isNot(contains('0 notifications')));
    expect(states.first, 'loading');
    expect(states.last, '8 notifications');
  });

  test('a post reloads with its comments, and never shows them gone '
      'meanwhile', () async {
    final states = record(
      postDetailControllerProvider('p1'),
      (state) => '${state.post.id}, ${state.comments.length} comments',
    );
    await container.read(postDetailControllerProvider('p1').future);
    await pumpEventQueue();
    states.clear();

    await clearCache();
    await container.read(postDetailControllerProvider('p1').future);
    await pumpEventQueue();

    expect(states, isNot(contains('p1, 0 comments')));
    expect(states.first, 'loading');
    expect(states.last, 'p1, 3 comments');
  });

  test('a profile reloads, and never shows "no posts" meanwhile', () async {
    final states = record(
      profileControllerProvider('u_ada'),
      (state) => '${state.user.name}: ${state.posts.length} posts',
    );
    await container.read(profileControllerProvider('u_ada').future);
    await pumpEventQueue();
    states.clear();

    await clearCache();
    await container.read(profileControllerProvider('u_ada').future);
    await pumpEventQueue();

    expect(states, isNot(contains('Ada Lovelace: 0 posts')));
    expect(states.first, 'loading');
    expect(states.last, 'Ada Lovelace: 3 posts');
  });

  test('a search on screen runs again: its posts come back', () async {
    final views = <SearchResultsView>[];
    container.listen(
      currentSearchResultsProvider,
      (_, next) => views.add(next),
      fireImmediately: true,
    );
    container.read(searchQueryControllerProvider.notifier).queryChanged('ada');
    await Future<void>.delayed(searchDebounce * 2);
    await pumpEventQueue();
    expect(views.last, isA<SearchFound>());

    await clearCache();
    await Future<void>.delayed(searchDebounce * 2);
    await pumpEventQueue();

    final found = views.last as SearchFound;
    expect(found.results.users.map((user) => user.id), ['u_ada']);
    expect(found.results.posts.map((post) => post.id), ['p1', 'p6', 'p11']);
  });
}
