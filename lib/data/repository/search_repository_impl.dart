import 'package:clock/clock.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/core/database/daos/search_dao.dart';
import 'package:connect_hub_riverpod/core/network/api/search_api_service.dart';
import 'package:connect_hub_riverpod/data/mapper/post_mappers.dart';
import 'package:connect_hub_riverpod/data/mapper/user_mappers.dart';
import 'package:connect_hub_riverpod/data/repository/api_guard.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/model/search_hits.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';

/// Search through the server, with results kept live by the cache.
///
/// The server's answer is cached like any other (people as users, posts as
/// posts; never in the feed), and the screen reads it back by id. So the
/// results follow every change made elsewhere: like a post from its detail
/// screen, come back, and the heart in the results is already red.
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._api, this._search, this._clock);

  final SearchApiService _api;
  final SearchDao _search;
  final Clock _clock;

  @override
  Future<Result<SearchHits>> search(String query) async {
    final result = await guardApiCall(() => _api.search(query));
    switch (result) {
      case Ok(value: final response):
        await _search.cacheResults(
          people: [for (final user in response.users) user.toRow()],
          posts: [for (final post in response.posts) post.toCached()],
        );
        return Ok(
          SearchHits(
            userIds: [for (final user in response.users) user.id],
            postIds: [for (final post in response.posts) post.id],
          ),
        );
      case Err(:final exception):
        return Err(exception);
    }
  }

  @override
  Stream<List<User>> watchPeople(List<String> ids) => _search
      .watchUsers(ids)
      .map(
        (rows) =>
            _inOrder(ids, [for (final row in rows) row.toDomain()], _userId),
      );

  @override
  Stream<List<Post>> watchPosts(List<String> ids) => _search
      .watchPosts(ids)
      .map(
        (entries) => _inOrder(ids, [
          for (final entry in entries) entry.toDomain(),
        ], _postId),
      );

  @override
  Stream<List<String>> watchRecentSearches() => _search
      .watchRecentSearches()
      .map((rows) => [for (final row in rows) row.displayText]);

  @override
  Future<void> saveRecentSearch(String query) =>
      _search.saveRecentSearch(query, at: _clock.now().toUtc());

  @override
  Future<void> clearRecentSearches() => _search.clearRecentSearches();

  static String _userId(User user) => user.id;
  static String _postId(Post post) => post.id;

  /// [items] in the order of [ids] (SQL returns rows in no particular
  /// order). An id that is no longer cached is skipped.
  static List<T> _inOrder<T>(
    List<String> ids,
    List<T> items,
    String Function(T item) idOf,
  ) {
    final byId = {for (final item in items) idOf(item): item};
    return [for (final id in ids) ?byId[id]];
  }
}
