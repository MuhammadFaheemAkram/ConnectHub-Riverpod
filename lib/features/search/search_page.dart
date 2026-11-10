import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/app_routes.dart';
import 'package:connect_hub_riverpod/domain/model/search_results.dart';
import 'package:connect_hub_riverpod/domain/model/search_scope.dart';
import 'package:connect_hub_riverpod/features/search/search_controller.dart';
import 'package:connect_hub_riverpod/features/search/search_state.dart';
import 'package:connect_hub_riverpod/features/search/widgets/recent_searches.dart';
import 'package:connect_hub_riverpod/features/search/widgets/search_result_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The Search tab: a search field, scope chips, and then the recent
/// searches (nothing typed), the results, or what went wrong.
///
/// A `ConsumerStatefulWidget` only for the field's controller: a tapped
/// recent search is written into the field.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _field = TextEditingController();

  SearchQueryController get _controller =>
      ref.read(searchQueryControllerProvider.notifier);

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _searchAgain(String query) {
    _field.text = query;
    _controller.recentSearchChosen(query);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      searchQueryControllerProvider.select((search) => search.message),
      (_, message) {
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        _controller.messageShown();
      },
    );

    final search = ref.watch(searchQueryControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.xxSmall,
              AppSpacing.medium,
              AppSpacing.xSmall,
            ),
            child: AppSearchField(
              controller: _field,
              hintText: 'Search people and posts',
              onChanged: _controller.queryChanged,
              onSubmitted: _controller.submitted,
              onCleared: () => _controller.queryChanged(''),
            ),
          ),
          _ScopeChips(
            selected: search.scope,
            onSelected: _controller.scopeChanged,
          ),
          Expanded(
            // Blank is idle at once: no provider to wait for.
            child: search.searchedQuery.isEmpty
                ? RecentSearches(
                    searches: ref.watch(recentSearchesProvider).value ?? [],
                    onSelected: _searchAgain,
                    onClear: _controller.clearHistory,
                  )
                : _Results(query: search.searchedQuery, scope: search.scope),
          ),
        ],
      ),
    );
  }
}

/// What the current query found, filtered by the scope.
class _Results extends ConsumerWidget {
  const _Results({required this.query, required this.scope});

  final String query;
  final SearchScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(searchQueryControllerProvider.notifier);
    void open(VoidCallback navigate) {
      controller.resultOpened();
      navigate();
    }

    final list = switch (ref.watch(currentSearchResultsProvider)) {
      SearchFound(:final results) => _list(context, controller, open, results),
      // The previous results stay, under a progress bar: no flicker.
      SearchSearching(previous: final previous?) => Column(
        children: [
          const LinearProgressIndicator(semanticsLabel: 'Searching'),
          Expanded(child: _list(context, controller, open, previous)),
        ],
      ),
      SearchSearching() => const LoadingView(message: 'Searching…'),
      SearchFailed(:final error) => ErrorView(
        message: error is AppException
            ? error.message
            : const UnknownException().message,
        // A new search for the same query: no automatic retry.
        onRetry: () => ref.invalidate(searchHitsProvider(query)),
      ),
      SearchIdle() => const SizedBox.shrink(),
    };
    return list;
  }

  Widget _list(
    BuildContext context,
    SearchQueryController controller,
    void Function(VoidCallback navigate) open,
    SearchResults results,
  ) {
    final shown = _shown(results);
    if (shown.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off,
        title: 'No results',
        message: _noMatchesMessage(scope, query),
      );
    }
    return SearchResultList(
      results: shown,
      onOpenPerson: (user) =>
          open(() => UserProfileRoute(userId: user.id).push<void>(context)),
      onOpenPost: (post) =>
          open(() => PostDetailRoute(postId: post.id).push<void>(context)),
      onLike: controller.toggleLike,
      onSave: controller.toggleSave,
    );
  }

  SearchResults _shown(SearchResults results) => switch (scope) {
    SearchScope.all => results,
    SearchScope.people => SearchResults(users: results.users),
    SearchScope.posts => SearchResults(posts: results.posts),
  };

  static String _noMatchesMessage(SearchScope scope, String query) =>
      switch (scope) {
        SearchScope.all => 'No people or posts match “$query”.',
        SearchScope.people => 'No people match “$query”.',
        SearchScope.posts => 'No posts match “$query”.',
      };
}

/// All · People · Posts. Only filters what the search already found.
class _ScopeChips extends StatelessWidget {
  const _ScopeChips({required this.selected, required this.onSelected});

  final SearchScope selected;
  final ValueChanged<SearchScope> onSelected;

  static const _labels = {
    SearchScope.all: 'All',
    SearchScope.people: 'People',
    SearchScope.posts: 'Posts',
  };

  @override
  Widget build(BuildContext context) {
    // A filter row starts at the leading edge, under the search field.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
        child: Wrap(
          spacing: AppSpacing.xSmall,
          children: [
            for (final MapEntry(key: scope, value: label) in _labels.entries)
              ChoiceChip(
                label: Text(label),
                selected: scope == selected,
                onSelected: (_) => onSelected(scope),
              ),
          ],
        ),
      ),
    );
  }
}
