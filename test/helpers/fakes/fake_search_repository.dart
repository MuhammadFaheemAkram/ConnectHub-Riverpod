import 'dart:async';

import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/model/search_hits.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';

/// A scriptable [SearchRepository]: what each query finds, the "cache" of
/// people and posts it reads back by id, and the recent searches.
///
/// Like drift, the watch streams emit now, then after every change,
/// asynchronously.
class FakeSearchRepository implements SearchRepository {
  FakeSearchRepository({
    List<User> people = const [],
    List<Post> posts = const [],
  }) {
    for (final user in people) {
      _people[user.id] = user;
    }
    for (final post in posts) {
      _posts[post.id] = post;
    }
  }

  final _people = <String, User>{};
  final _posts = <String, Post>{};
  final _recent = <String>[];
  final _changes = StreamController<void>.broadcast();

  /// What each query finds; a query missing here finds nothing.
  final hitsFor = <String, SearchHits>{};

  /// When set, every search fails with it.
  Result<SearchHits>? failure;

  /// Every query searched, in order.
  final searchCalls = <String>[];

  /// The recent searches now, newest first (read directly: awaiting a
  /// stream in a widget test's fake time can hang).
  List<String> get recent => List.unmodifiable(_recent);

  @override
  Future<Result<SearchHits>> search(String query) async {
    searchCalls.add(query);
    return failure ?? Ok(hitsFor[query] ?? const SearchHits());
  }

  @override
  Stream<List<User>> watchPeople(List<String> ids) =>
      _watch(() => [for (final id in ids) ?_people[id]]);

  @override
  Stream<List<Post>> watchPosts(List<String> ids) =>
      _watch(() => [for (final id in ids) ?_posts[id]]);

  @override
  Stream<List<String>> watchRecentSearches() => _watch(() => List.of(_recent));

  @override
  Future<void> saveRecentSearch(String query) async {
    final text = query.trim();
    _recent
      ..removeWhere((recent) => recent.toLowerCase() == text.toLowerCase())
      ..insert(0, text);
    _changes.add(null);
  }

  @override
  Future<void> clearRecentSearches() async {
    _recent.clear();
    _changes.add(null);
  }

  /// Changes a cached post, as a like on another screen would.
  void replacePost(Post post) {
    _posts[post.id] = post;
    _changes.add(null);
  }

  Stream<T> _watch<T>(T Function() read) => Stream.multi((watcher) {
    final subscription = _changes.stream.listen((_) => watcher.add(read()));
    watcher
      ..onCancel = subscription.cancel
      ..add(read());
  });

  Future<void> dispose() => _changes.close();
}
