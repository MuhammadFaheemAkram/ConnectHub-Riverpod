// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What [query] matched, as ids: **debounced through disposal**.
///
/// - A family keyed by the (trimmed) query: each query is its own provider.
/// - It waits [searchDebounce] first. If the user types on, the screen
///   watches another query's provider, this one is disposed, and
///   `ref.debounce` cancels the wait: no request is ever sent for it.
/// - A failure is thrown, so the screen sees `AsyncError` and offers
///   "Try again" (which invalidates this provider).

@ProviderFor(searchHits)
final searchHitsProvider = SearchHitsFamily._();

/// What [query] matched, as ids: **debounced through disposal**.
///
/// - A family keyed by the (trimmed) query: each query is its own provider.
/// - It waits [searchDebounce] first. If the user types on, the screen
///   watches another query's provider, this one is disposed, and
///   `ref.debounce` cancels the wait: no request is ever sent for it.
/// - A failure is thrown, so the screen sees `AsyncError` and offers
///   "Try again" (which invalidates this provider).

final class SearchHitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SearchHits>,
          SearchHits,
          FutureOr<SearchHits>
        >
    with $FutureModifier<SearchHits>, $FutureProvider<SearchHits> {
  /// What [query] matched, as ids: **debounced through disposal**.
  ///
  /// - A family keyed by the (trimmed) query: each query is its own provider.
  /// - It waits [searchDebounce] first. If the user types on, the screen
  ///   watches another query's provider, this one is disposed, and
  ///   `ref.debounce` cancels the wait: no request is ever sent for it.
  /// - A failure is thrown, so the screen sees `AsyncError` and offers
  ///   "Try again" (which invalidates this provider).
  SearchHitsProvider._({
    required SearchHitsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchHitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchHitsHash();

  @override
  String toString() {
    return r'searchHitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SearchHits> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SearchHits> create(Ref ref) {
    final argument = this.argument as String;
    return searchHits(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchHitsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchHitsHash() => r'f1bcbd0b0965026ab48b70e96fb3965716533156';

/// What [query] matched, as ids: **debounced through disposal**.
///
/// - A family keyed by the (trimmed) query: each query is its own provider.
/// - It waits [searchDebounce] first. If the user types on, the screen
///   watches another query's provider, this one is disposed, and
///   `ref.debounce` cancels the wait: no request is ever sent for it.
/// - A failure is thrown, so the screen sees `AsyncError` and offers
///   "Try again" (which invalidates this provider).

final class SearchHitsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SearchHits>, String> {
  SearchHitsFamily._()
    : super(
        retry: null,
        name: r'searchHitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What [query] matched, as ids: **debounced through disposal**.
  ///
  /// - A family keyed by the (trimmed) query: each query is its own provider.
  /// - It waits [searchDebounce] first. If the user types on, the screen
  ///   watches another query's provider, this one is disposed, and
  ///   `ref.debounce` cancels the wait: no request is ever sent for it.
  /// - A failure is thrown, so the screen sees `AsyncError` and offers
  ///   "Try again" (which invalidates this provider).

  SearchHitsProvider call(String query) =>
      SearchHitsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchHitsProvider';
}

/// The people [query] found, live from the cache.

@ProviderFor(searchPeople)
final searchPeopleProvider = SearchPeopleFamily._();

/// The people [query] found, live from the cache.

final class SearchPeopleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<User>>,
          List<User>,
          Stream<List<User>>
        >
    with $FutureModifier<List<User>>, $StreamProvider<List<User>> {
  /// The people [query] found, live from the cache.
  SearchPeopleProvider._({
    required SearchPeopleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchPeopleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchPeopleHash();

  @override
  String toString() {
    return r'searchPeopleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<User>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<User>> create(Ref ref) {
    final argument = this.argument as String;
    return searchPeople(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchPeopleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchPeopleHash() => r'ed33a8eab744aee1855780c8399fdb9b5e2ca4e6';

/// The people [query] found, live from the cache.

final class SearchPeopleFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<User>>, String> {
  SearchPeopleFamily._()
    : super(
        retry: null,
        name: r'searchPeopleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The people [query] found, live from the cache.

  SearchPeopleProvider call(String query) =>
      SearchPeopleProvider._(argument: query, from: this);

  @override
  String toString() => r'searchPeopleProvider';
}

/// The posts [query] found, live from the cache: a like anywhere shows here.

@ProviderFor(searchPosts)
final searchPostsProvider = SearchPostsFamily._();

/// The posts [query] found, live from the cache: a like anywhere shows here.

final class SearchPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          Stream<List<Post>>
        >
    with $FutureModifier<List<Post>>, $StreamProvider<List<Post>> {
  /// The posts [query] found, live from the cache: a like anywhere shows here.
  SearchPostsProvider._({
    required SearchPostsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchPostsHash();

  @override
  String toString() {
    return r'searchPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Post>> create(Ref ref) {
    final argument = this.argument as String;
    return searchPosts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchPostsHash() => r'c663527883e6362c1c19fb26f5fc9fefb44bfd15';

/// The posts [query] found, live from the cache: a like anywhere shows here.

final class SearchPostsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Post>>, String> {
  SearchPostsFamily._()
    : super(
        retry: null,
        name: r'searchPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The posts [query] found, live from the cache: a like anywhere shows here.

  SearchPostsProvider call(String query) =>
      SearchPostsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchPostsProvider';
}

/// The two live sections, combined with `ref.watch`: no `combineLatest`.
/// Either section changing rebuilds this one.

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsFamily._();

/// The two live sections, combined with `ref.watch`: no `combineLatest`.
/// Either section changing rebuilds this one.

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SearchResults>,
          SearchResults,
          FutureOr<SearchResults>
        >
    with $FutureModifier<SearchResults>, $FutureProvider<SearchResults> {
  /// The two live sections, combined with `ref.watch`: no `combineLatest`.
  /// Either section changing rebuilds this one.
  SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SearchResults> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SearchResults> create(Ref ref) {
    final argument = this.argument as String;
    return searchResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'dfb2a40b46700f2f0d3548628ca69bb5b53e5de0';

/// The two live sections, combined with `ref.watch`: no `combineLatest`.
/// Either section changing rebuilds this one.

final class SearchResultsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SearchResults>, String> {
  SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The two live sections, combined with `ref.watch`: no `combineLatest`.
  /// Either section changing rebuilds this one.

  SearchResultsProvider call(String query) =>
      SearchResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchResultsProvider';
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

@ProviderFor(CurrentSearchResults)
final currentSearchResultsProvider = CurrentSearchResultsProvider._();

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
final class CurrentSearchResultsProvider
    extends $NotifierProvider<CurrentSearchResults, SearchResultsView> {
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
  CurrentSearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSearchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSearchResultsHash();

  @$internal
  @override
  CurrentSearchResults create() => CurrentSearchResults();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchResultsView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchResultsView>(value),
    );
  }
}

String _$currentSearchResultsHash() =>
    r'c4767e127c517e7e9792b05c984972acab5bc0a3';

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

abstract class _$CurrentSearchResults extends $Notifier<SearchResultsView> {
  SearchResultsView build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchResultsView, SearchResultsView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchResultsView, SearchResultsView>,
              SearchResultsView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The recent searches, newest first, live.

@ProviderFor(recentSearches)
final recentSearchesProvider = RecentSearchesProvider._();

/// The recent searches, newest first, live.

final class RecentSearchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// The recent searches, newest first, live.
  RecentSearchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return recentSearches(ref);
  }
}

String _$recentSearchesHash() => r'249c5d528ed5606fa749665bba4e0c5400ae4b00';

/// The Search tab's input: the query, the scope, recent searches, and
/// likes and saves in the results.
///
/// Named for what it holds: `SearchController` is taken by Material.
/// Auto-dispose: the tab shell keeps the Search tab mounted, so the query
/// survives tab switches.

@ProviderFor(SearchQueryController)
final searchQueryControllerProvider = SearchQueryControllerProvider._();

/// The Search tab's input: the query, the scope, recent searches, and
/// likes and saves in the results.
///
/// Named for what it holds: `SearchController` is taken by Material.
/// Auto-dispose: the tab shell keeps the Search tab mounted, so the query
/// survives tab switches.
final class SearchQueryControllerProvider
    extends $NotifierProvider<SearchQueryController, SearchState> {
  /// The Search tab's input: the query, the scope, recent searches, and
  /// likes and saves in the results.
  ///
  /// Named for what it holds: `SearchController` is taken by Material.
  /// Auto-dispose: the tab shell keeps the Search tab mounted, so the query
  /// survives tab switches.
  SearchQueryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryControllerHash();

  @$internal
  @override
  SearchQueryController create() => SearchQueryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchQueryControllerHash() =>
    r'9592b5b3d2900499239d1c50e098ad152968ef25';

/// The Search tab's input: the query, the scope, recent searches, and
/// likes and saves in the results.
///
/// Named for what it holds: `SearchController` is taken by Material.
/// Auto-dispose: the tab shell keeps the Search tab mounted, so the query
/// survives tab switches.

abstract class _$SearchQueryController extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
