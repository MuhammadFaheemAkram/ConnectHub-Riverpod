import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';

/// Remembers a query as the newest recent search (blank queries are not
/// saved).
class SaveRecentSearchUseCase {
  const SaveRecentSearchUseCase(this._search);

  final SearchRepository _search;

  Future<void> call(String query) async {
    if (query.trim().isEmpty) return;
    await _search.saveRecentSearch(query);
  }
}
