import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';

/// The recent searches, newest first.
class WatchRecentSearchesUseCase {
  const WatchRecentSearchesUseCase(this._search);

  final SearchRepository _search;

  Stream<List<String>> call() => _search.watchRecentSearches();
}
