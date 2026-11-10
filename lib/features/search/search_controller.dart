import 'package:connect_hub_riverpod/core/common/debounce.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/use_case_providers.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/model/search_hits.dart';
import 'package:connect_hub_riverpod/domain/model/search_results.dart';
import 'package:connect_hub_riverpod/domain/model/search_scope.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:connect_hub_riverpod/features/search/search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_controller.g.dart';

/// How long typing must pause before a query is searched.
const searchDebounce = Duration(milliseconds: 300);

/// What [query] matched, as ids: **debounced through disposal**.
///
/// - A family keyed by the (trimmed) query: each query is its own provider.
/// - It waits [searchDebounce] first. If the user types on, the screen
///   watches another query's provider, this one is disposed, and
///   `ref.debounce` cancels the wait: no request is ever sent for it.
/// - A failure is thrown, so the screen sees `AsyncError` and offers
///   "Try again" (which invalidates this provider).
@riverpod
Future<SearchHits> searchHits(Ref ref, String query) async {
  await ref.debounce(searchDebounce);
  return switch (await ref.read(searchUseCaseProvider)(query)) {
    Ok(:final value) => value,
    Err(:final exception) => throw exception,
  };
}

/// The people [query] found, live from the cache.
@riverpod
Stream<List<User>> searchPeople(Ref ref, String query) async* {
  // Watch what is needed before the first await.
  final watchPeople = ref.watch(watchSearchPeopleUseCaseProvider);
  final hits = await ref.watch(searchHitsProvider(query).future);
  yield* watchPeople(hits.userIds);
}

/// The posts [query] found, live from the cache: a like anywhere shows here.
@riverpod
Stream<List<Post>> searchPosts(Ref ref, String query) async* {
  final watchPosts = ref.watch(watchSearchPostsUseCaseProvider);
  final hits = await ref.watch(searchHitsProvider(query).future);
  yield* watchPosts(hits.postIds);
}

/// The two live sections, combined with `ref.watch`: no `combineLatest`.
/// Either section changing rebuilds this one.
@riverpod
Future<SearchResults> searchResults(Ref ref, String query) async {
  final people = ref.watch(searchPeopleProvider(query).future);
  final posts = ref.watch(searchPostsProvider(query).future);
  return SearchResults(users: await people, posts: await posts);
}

/// The results area for whatever is in the search field now.
///
/// - It **watches** the query, and the current query's
///   [searchResultsProvider] only, so every older query is disposed (and
///   its debounce cancelled) as soon as the user types on.
/// - **Synchronous on purpose.** When a provider rebuilds, Riverpod 3 keeps
///   its previous dependencies (paused) until the new build *completes*. An
///   async provider here would take the whole debounce to complete, and
///   keep every query typed meanwhile alive, so each would be searched in
///   turn. A synchronous build completes at once and lets go of the old
///   query immediately (a test types "a", "ad", "ada" and sees one search).
/// - It remembers the last results it showed, so they stay on screen while
///   the next query is debounced and searched (a notifier's fields survive
///   its rebuilds).
@riverpod
class CurrentSearchResults extends _$CurrentSearchResults {
  SearchResults? _shown;

  @override
  SearchResultsView build() {
    final query = ref.watch(
      searchQueryControllerProvider.select((search) => search.searchedQuery),
    );
    // Blank is idle at once: nothing is searched.
    if (query.isEmpty) {
      _shown = null;
      return const SearchResultsView.idle();
    }
    final results = ref.watch(searchResultsProvider(query));
    if (results.value case final found?) {
      _shown = found;
      return SearchResultsView.found(found);
    }
    if (results.isLoading) return SearchResultsView.searching(previous: _shown);
    return SearchResultsView.failed(results.error!);
  }
}

/// The recent searches, newest first, live.
@riverpod
Stream<List<String>> recentSearches(Ref ref) =>
    ref.watch(watchRecentSearchesUseCaseProvider)();

/// The Search tab's input: the query, the scope, recent searches, and
/// likes and saves in the results.
///
/// Named for what it holds: `SearchController` is taken by Material.
/// Auto-dispose: the tab shell keeps the Search tab mounted, so the query
/// survives tab switches.
@riverpod
class SearchQueryController extends _$SearchQueryController {
  static const likeFailedMessage =
      "Couldn't update the like. Please try again.";
  static const saveFailedMessage =
      "Couldn't update the save. Please try again.";

  @override
  SearchState build() => const SearchState();

  void queryChanged(String query) => state = state.copyWith(query: query);

  /// The scope only filters what is on screen: the server always answers
  /// with both people and posts, so no new request.
  void scopeChanged(SearchScope scope) => state = state.copyWith(scope: scope);

  /// The keyboard's search key: the query is searched and becomes a recent
  /// search.
  Future<void> submitted(String query) async {
    state = state.copyWith(query: query);
    await ref.read(saveRecentSearchUseCaseProvider)(query);
  }

  /// A result was tapped: what found it becomes a recent search.
  Future<void> resultOpened() =>
      ref.read(saveRecentSearchUseCaseProvider)(state.query);

  /// A recent search tapped: search it again (and move it to the top).
  Future<void> recentSearchChosen(String query) => submitted(query);

  Future<void> clearHistory() => ref.read(clearRecentSearchesUseCaseProvider)();

  Future<void> toggleLike(Post post) async {
    final result = await ref.read(likePostUseCaseProvider)(
      post.id,
      liked: !post.isLiked,
    );
    if (!ref.mounted) return;
    if (result is Err<void>) {
      state = state.copyWith(message: likeFailedMessage);
    }
  }

  Future<void> toggleSave(Post post) async {
    final result = await ref.read(savePostUseCaseProvider)(
      post.id,
      saved: !post.isBookmarked,
    );
    if (!ref.mounted) return;
    if (result is Err<void>) {
      state = state.copyWith(message: saveFailedMessage);
    }
  }

  void messageShown() => state = state.copyWith(message: null);
}
