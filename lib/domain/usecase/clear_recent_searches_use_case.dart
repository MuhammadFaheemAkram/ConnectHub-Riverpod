import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';

/// Forgets every recent search.
class ClearRecentSearchesUseCase {
  const ClearRecentSearchesUseCase(this._search);

  final SearchRepository _search;

  Future<void> call() => _search.clearRecentSearches();
}
