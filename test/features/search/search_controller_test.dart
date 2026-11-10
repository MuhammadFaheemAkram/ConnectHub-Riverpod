import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/model/search_hits.dart';
import 'package:connect_hub_riverpod/domain/model/search_scope.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:connect_hub_riverpod/features/search/search_controller.dart';
import 'package:connect_hub_riverpod/features/search/search_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_post_repository.dart';
import '../../helpers/fakes/fake_search_repository.dart';
import '../../helpers/fixtures.dart';

// Search's providers in fake time: the debounce, the newest query winning,
// live results, and recent searches. The repository is a fake (no drift:
// fake time and drift don't mix, conventions §11.27).
void main() {
  const grace = User(id: 'u_grace', name: 'Grace Hopper');
  final p1 = samplePost('p1');

  late FakeSearchRepository search;
  late FakePostRepository posts;

  setUp(() {
    search = FakeSearchRepository(people: [ada, grace], posts: [p1])
      ..hitsFor['ada'] = const SearchHits(userIds: ['u_ada'], postIds: ['p1'])
      ..hitsFor['grace'] = const SearchHits(userIds: ['u_grace']);
    posts = FakePostRepository();
  });

  tearDown(() async {
    await search.dispose();
    await posts.dispose();
  });

  /// Runs [body] in fake time with a container whose screen watches the
  /// current results, as the Search page does.
  void inFakeTime(
    void Function(
      FakeAsync async,
      ProviderContainer container,
      List<SearchResultsView> states,
    )
    body,
  ) {
    fakeAsync((async) {
      final container = testContainer(
        overrides: [
          searchRepositoryProvider.overrideWithValue(search),
          postRepositoryProvider.overrideWithValue(posts),
        ],
      );
      final states = <SearchResultsView>[];
      container.listen(
        currentSearchResultsProvider,
        (_, next) => states.add(next),
      );
      body(async, container, states);
      async.flushMicrotasks();
    });
  }

  SearchQueryController controller(ProviderContainer container) =>
      container.read(searchQueryControllerProvider.notifier);

  const pause = Duration(milliseconds: 300);
  const keystroke = Duration(milliseconds: 100);

  group('debounce', () {
    test('a query is searched after 300 ms of quiet, not before', () {
      inFakeTime((async, container, _) {
        controller(container).queryChanged('ada');

        async.elapse(pause - const Duration(milliseconds: 1));
        expect(search.searchCalls, isEmpty);

        async.elapse(const Duration(milliseconds: 1));
        expect(search.searchCalls, ['ada']);
      });
    });

    test('typing on: only the newest query is ever searched; the others '
        'are disposed before they send anything', () {
      inFakeTime((async, container, _) {
        for (final query in ['a', 'ad', 'ada']) {
          controller(container).queryChanged(query);
          async.elapse(keystroke);
        }
        async.elapse(pause);

        expect(search.searchCalls, ['ada']);
        expect(container.read(searchHitsProvider('a').exists), isFalse);
        expect(container.read(searchHitsProvider('ad').exists), isFalse);
      });
    });

    test('the query is trimmed: " ada " and "ada" are one search', () {
      inFakeTime((async, container, _) {
        controller(container).queryChanged(' ada ');
        async.elapse(pause);

        expect(search.searchCalls, ['ada']);
      });
    });

    test('a blank query is idle at once: nothing is searched, and no timer '
        'is left behind', () {
      inFakeTime((async, container, states) {
        controller(container).queryChanged('ada');
        async.elapse(keystroke);
        controller(container).queryChanged('   ');
        async.elapse(const Duration(seconds: 1));

        expect(search.searchCalls, isEmpty);
        expect(states.last, const SearchResultsView.idle());
        expect(async.pendingTimers, isEmpty);
      });
    });
  });

  group('results', () {
    test('people and posts, in the order found', () {
      inFakeTime((async, container, states) {
        controller(container).queryChanged('ada');
        async.elapse(pause);

        final results = (states.last as SearchFound).results;
        expect(results.users, [ada]);
        expect(results.posts, [p1]);
      });
    });

    test('while the next query waits, the previous results stay: no '
        'flicker', () {
      inFakeTime((async, container, states) {
        controller(container).queryChanged('ada');
        async.elapse(pause);

        controller(container).queryChanged('grace');
        async.elapse(keystroke);
        final waiting = container.read(currentSearchResultsProvider);
        expect(waiting, isA<SearchSearching>());
        expect((waiting as SearchSearching).previous?.users, [ada]);

        async.elapse(pause);
        final found = container.read(currentSearchResultsProvider);
        expect((found as SearchFound).results.users, [grace]);
      });
    });

    test('live: a like elsewhere shows in the results without searching '
        'again', () {
      inFakeTime((async, container, states) {
        controller(container).queryChanged('ada');
        async.elapse(pause);

        search.replacePost(p1.copyWith(isLiked: true, likeCount: 11));
        // Rebuilds run on the scheduler's next tick, not in a microtask.
        async.elapse(Duration.zero);

        expect(
          (states.last as SearchFound).results.posts.single.isLiked,
          isTrue,
        );
        expect(search.searchCalls, ['ada']);
      });
    });

    test('a failure is an error; "Try again" searches the same query '
        'again', () {
      inFakeTime((async, container, states) {
        search.failure = const Err(NetworkException());
        controller(container).queryChanged('ada');
        async.elapse(pause);
        expect(
          states.last,
          isA<SearchFailed>().having(
            (failed) => failed.error,
            'error',
            isA<NetworkException>(),
          ),
        );

        search.failure = null;
        container.invalidate(searchHitsProvider('ada'));
        async.elapse(pause);

        expect((states.last as SearchFound).results.users, [ada]);
        expect(search.searchCalls, ['ada', 'ada']);
      });
    });

    test('changing the scope searches nothing again', () {
      inFakeTime((async, container, _) {
        controller(container).queryChanged('ada');
        async.elapse(pause);

        controller(container).scopeChanged(SearchScope.people);
        async.elapse(pause);

        expect(search.searchCalls, ['ada']);
      });
    });
  });

  group('recent searches', () {
    test('typing saves nothing; the search key and opening a result do', () {
      inFakeTime((async, container, _) {
        final recent = <List<String>>[];
        container.listen(
          recentSearchesProvider,
          (_, next) => recent.add(next.value ?? []),
          fireImmediately: true,
        );

        controller(container).queryChanged('ada');
        async.elapse(pause);
        expect(recent.last, isEmpty);

        controller(container).submitted('ada');
        async.flushMicrotasks();
        expect(recent.last, ['ada']);

        controller(container).queryChanged('grace');
        controller(container).resultOpened();
        async.flushMicrotasks();
        expect(recent.last, ['grace', 'ada']);

        controller(container).clearHistory();
        async.flushMicrotasks();
        expect(recent.last, isEmpty);
      });
    });

    test('a recent search tapped is searched again', () {
      inFakeTime((async, container, _) {
        controller(container).recentSearchChosen('grace');
        async.elapse(pause);

        expect(container.read(searchQueryControllerProvider).query, 'grace');
        expect(search.searchCalls, ['grace']);
      });
    });
  });

  test('a like that fails in the results says so', () {
    inFakeTime((async, container, _) {
      posts.likeResult = const Err(NetworkException());

      controller(container).toggleLike(p1);
      async.flushMicrotasks();

      expect(
        container.read(searchQueryControllerProvider).message,
        SearchQueryController.likeFailedMessage,
      );
    });
  });
}
