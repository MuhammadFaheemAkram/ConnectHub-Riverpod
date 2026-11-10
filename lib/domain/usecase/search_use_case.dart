import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/model/search_hits.dart';
import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';

/// Searches people and posts for a trimmed query; caches what it found.
class SearchUseCase {
  const SearchUseCase(this._search);

  final SearchRepository _search;

  Future<Result<SearchHits>> call(String query) => _search.search(query.trim());
}
