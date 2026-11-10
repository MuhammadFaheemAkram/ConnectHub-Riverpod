import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/model/search_hits.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';

/// Searching people and posts, and the list of recent searches.
///
/// A search is two steps, so its results stay live:
/// 1. [search] asks the server, caches what it found, and returns the ids;
/// 2. [watchPeople] and [watchPosts] read those ids from the cache, so a
///    like or a save made on any screen shows in the results at once.
///
/// Two streams, not one: the app combines them with `ref.watch` in a
/// provider (ConnectHub-Flutter merged them here with `combineLatest`).
abstract interface class SearchRepository {
  Future<Result<SearchHits>> search(String query);

  /// The cached people among [ids], in that order: now, then after every
  /// change. One that leaves the cache drops out.
  Stream<List<User>> watchPeople(List<String> ids);

  /// The cached posts among [ids], in that order: now, then after every
  /// change.
  Stream<List<Post>> watchPosts(List<String> ids);

  /// The recent searches, newest first (at most 10).
  Stream<List<String>> watchRecentSearches();

  /// Remembers [query] as the newest recent search: trimmed, one entry per
  /// query ignoring case, at most 10.
  Future<void> saveRecentSearch(String query);

  Future<void> clearRecentSearches();
}
