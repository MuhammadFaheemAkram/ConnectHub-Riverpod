import 'package:connect_hub_riverpod/domain/model/search_results.dart';
import 'package:connect_hub_riverpod/domain/model/search_scope.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

/// What the user asked for: the text in the search field and the scope.
///
/// The results are not in here: they are their own providers, keyed by the
/// query (`searchResultsProvider(query)`), so each query has its own
/// lifetime, and dropping an old one cancels its search.
@freezed
abstract class SearchState with _$SearchState {
  const SearchState._();

  const factory SearchState({
    /// As typed; trimmed when searched.
    @Default('') String query,
    @Default(SearchScope.all) SearchScope scope,

    /// A one-off SnackBar (a like or a save that failed in the results).
    String? message,
  }) = _SearchState;

  /// What is searched: the query without surrounding spaces. Blank means
  /// idle: the recent searches show.
  String get searchedQuery => query.trim();
}

/// What the results area shows for the current query.
@freezed
sealed class SearchResultsView with _$SearchResultsView {
  /// Nothing typed: the recent searches show.
  const factory SearchResultsView.idle() = SearchIdle;

  /// The current query is being debounced or searched. [previous] is what
  /// the last query found, kept on screen meanwhile (no flicker); `null` on
  /// a first search.
  const factory SearchResultsView.searching({SearchResults? previous}) =
      SearchSearching;

  /// What the current query found, live.
  const factory SearchResultsView.found(SearchResults results) = SearchFound;

  /// The current query's search failed.
  const factory SearchResultsView.failed(Object error) = SearchFailed;
}
