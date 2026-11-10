# Bloc vs Riverpod: one app, two editions

[ConnectHub-Flutter](https://github.com/MuhammadFaheemAkram/ConnectHub-Flutter) and this repo build the same social app on the same domain and data layers:
- the same fake server, drift tables, repositories and use cases;
- the same screens and seed.

What differs is the **presentation layer and the dependency injection**:

| | ConnectHub-Flutter | ConnectHub Riverpod |
|---|---|---|
| Screen state | `Cubit` / `Bloc` (`flutter_bloc`) | `Notifier` / `AsyncNotifier` (`flutter_riverpod` 3, generated) |
| Dependency injection | `get_it` + `injectable` (a service locator) | providers (a graph), overridden in tests |
| Scoping | `BlocProvider` in the widget tree | auto-dispose (the default) and `keepAlive` |
| Tests | `bloc_test`, `mocktail`, `MockCubit` | `ProviderContainer.test(overrides:)`, hand-written fakes |

The code below is taken from both repos as they are. ConnectHub-Flutter has more scope (sign-in, chat, a language label), so its classes do a little more. The comparison notes where that matters.

---

## 1. Data flow

**ConnectHub-Flutter:**

```
View ──(method call / event)──▶ Cubit / Bloc ──▶ UseCase ──▶ Repository ──▶ drift ◀── Fake API
  ▲                                │                                          │
  └──── BlocBuilder / BlocSelector ┘◀──────── emit(state) ◀──── stream.listen ┘
        BlocListener (effects)
dependencies: getIt<FeedCubit>() in the Page; the Cubit's constructor receives use cases (injectable)
```

**ConnectHub Riverpod:**

```
Widget ──ref.read(provider.notifier).method()──▶ Notifier ──ref.read(useCaseProvider)──▶ UseCase ──▶ Repository ──▶ drift ◀── Fake API
  ▲                                                │                                                              │
  └──── ref.watch(provider) / .select ◀─── state = …  ◀──── ref.listen(streamProvider) ◀─── stream provider ◀──────┘
        ref.listen (effects)
dependencies: every object is a provider; the Notifier reads what it needs through `ref`
```

The arrows are the same. Two things move:
- **Who creates the state holder:** a `BlocProvider(create: …)` in the widget tree, or the provider itself, the first time something watches it.
- **How dependencies arrive:** constructor parameters filled by a locator, or `ref.read` / `ref.watch` inside the notifier.

---

## 2. The Feed

### State holder

**Bloc** (`features/feed/cubit/feed_cubit.dart`, abridged):

```dart
@injectable
class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._watchFeed, this._refreshFeed, this._loadMoreFeed,
      this._likePost, this._bookmarkPost, WatchCacheClearedUseCase watchCacheCleared)
      : super(const FeedState.loading()) {
    _subscription = _watchFeed().listen(_onPosts);
    _cacheCleared = watchCacheCleared().listen((_) => load());
  }

  List<Post>? _posts;
  _Refresh _refresh = _Refresh.pending;
  …
  void _emitState() {
    if (isClosed) return;
    final next = switch (_posts) {
      null => const FeedState.loading(),
      [] => switch (_refresh) {
        _Refresh.pending => const FeedState.loading(),
        _Refresh.failed => FeedState.error(_refreshError),
        _Refresh.succeeded => const FeedState.empty(),
      },
      final posts => FeedState.loaded(posts: posts, hasMore: _hasMore, …),
    };
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _cacheCleared.cancel();
    return super.close();
  }
}
```

**Riverpod** (`features/feed/feed_controller.dart`, abridged):

```dart
@riverpod
Stream<List<Post>> feedPosts(Ref ref) => ref.watch(watchFeedUseCaseProvider)();

@riverpod
class FeedController extends _$FeedController {
  @override
  Future<FeedState> build() async {
    ref.watch(cacheEpochProvider);                       // Clear cache → rebuild → load again
    ref.listen(feedPostsProvider, (_, next) {            // drift changes patch the posts
      if (next case AsyncData(value: final posts)) {
        _update((feed) => feed.copyWith(posts: posts));
      }
    });
    final cached = await _readCache();
    if (cached.isNotEmpty) {
      unawaited(Future(refresh));                        // offline-first: refresh behind the cache
      return FeedState(posts: cached);
    }
    switch (await ref.read(refreshFeedUseCaseProvider)()) {
      case Ok(value: final hasMore):
        return FeedState(posts: await _readCache(), loadMore: _status(hasMore));
      case Err(:final exception):
        throw exception;                                 // → AsyncError, "Try again"
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    final result = await ref.read(refreshFeedUseCaseProvider)();
    if (!ref.mounted) return;                            // disposed while in flight
    …
  }
}
```

**What changed:**
- **Loading and error:**
  - The Cubit keeps a `_Refresh` enum and a hand-written `loading / error / empty / loaded` union to tell "still loading" from "empty" and "failed".
  - The `AsyncNotifier` gets loading and error from `AsyncValue`: `build` is awaited, and a `throw` becomes `AsyncError`. Its own state only needs the data (`posts`, `loadMore`, `message`).
- **Subscriptions:**
  - The Cubit subscribes in its constructor and cancels in `close()`.
  - The notifier `ref.listen`s a stream provider, and Riverpod cancels it when the notifier is disposed.
- **"Closed" checks:** `isClosed` and `ref.mounted` are the same idea. Both are needed after every `await`.
- **Clear cache:** a stream of "cleared" events that each Cubit listens to, versus one `ref.watch(cacheEpochProvider)` line that rebuilds the notifier.

### The page

**Bloc** (`features/feed/feed_page.dart`):

```dart
return BlocProvider(
  create: (_) => getIt<FeedCubit>()..load(),
  child: FeedView(
    onOpenPost: (postId) => PostDetailRoute(postId: postId).push<void>(context),
    …
  ),
);
// FeedView: BlocBuilder<FeedCubit, FeedState> for the list,
//           BlocListener for the SnackBar.
```

**Riverpod** (`features/feed/feed_page.dart`):

```dart
class FeedPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(feedControllerProvider.select((feed) => feed.value?.message), (_, message) {
      if (message == null) return;
      ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
      ref.read(feedControllerProvider.notifier).messageShown();
    });

    final feed = ref.watch(feedControllerProvider);
    return Scaffold(
      body: switch (feed) {
        AsyncValue(value: final state?) when state.posts.isEmpty => EmptyFeed(…),
        AsyncValue(value: final state?) => PostList(state: state, …),
        AsyncValue(isLoading: true) => const LoadingView(),
        AsyncError(:final error) => ErrorView(…, onRetry: () => ref.invalidate(feedControllerProvider)),
        …
      },
    );
  }
}
```

**What changed:**
- **No Page/View split:** the Bloc edition splits a Page (creates and provides the Cubit) from a View (renders it), so the View can be tested with a `MockCubit`. Here the page watches a provider, and tests override the *repository* under it instead, so one widget is enough.
- **No explicit `load()`:** the first `ref.watch` creates the notifier and runs `build`. "Try again" is `ref.invalidate(feedControllerProvider)`, which runs `build` again.
- **`select` in both:** `BlocSelector` / `context.select` versus `provider.select(...)`.

---

## 3. Search: `restartable()` vs disposal

**Bloc** (`features/search/bloc/search_transformers.dart` and `search_bloc.dart`):

```dart
EventTransformer<SearchQueryChanged> debounceRestartable(Duration duration) {
  return (events, mapper) => restartable<SearchQueryChanged>()(
    events.switchMap(
      (event) => event.immediate || event.query.trim().isEmpty
          ? Stream.value(event)
          : Stream.fromFuture(Future<SearchQueryChanged>.delayed(duration, () => event)),
    ),
    mapper,
  );
}

on<SearchQueryChanged>(_onQueryChanged, transformer: debounceRestartable(debounce));

Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
  …
  emit(state.copyWith(status: SearchStatus.loading, query: query));
  final result = await _search(query);
  if (emit.isDone) return;                 // a newer query restarted this handler
  switch (result) {
    case Ok(value: final hits):
      await _follow(hits, emit);           // emit.forEach over the live results
    case Err(:final exception):
      emit(state.copyWith(status: SearchStatus.failure, …));
  }
}
```

**Riverpod** (`core/common/debounce.dart` and `features/search/search_controller.dart`):

```dart
extension DebounceRef on Ref {
  Future<void> debounce(Duration delay) {
    final waited = Completer<void>();
    final timer = Timer(delay, waited.complete);
    onDispose(timer.cancel);               // disposed → never completes
    return waited.future;
  }
}

@riverpod
Future<SearchHits> searchHits(Ref ref, String query) async {
  ref.watch(cacheEpochProvider);
  await ref.debounce(searchDebounce);
  return switch (await ref.read(searchUseCaseProvider)(query)) {
    Ok(:final value) => value,
    Err(:final exception) => throw exception,
  };
}

@riverpod
Future<SearchResults> searchResults(Ref ref, String query) async {
  final people = ref.watch(searchPeopleProvider(query).future);   // live from drift
  final posts = ref.watch(searchPostsProvider(query).future);
  return SearchResults(users: await people, posts: await posts);
}

@riverpod
class CurrentSearchResults extends _$CurrentSearchResults {   // synchronous on purpose
  SearchResults? _shown;
  @override
  SearchResultsView build() {
    final query = ref.watch(searchQueryControllerProvider.select((s) => s.searchedQuery));
    if (query.isEmpty) return const SearchResultsView.idle();
    final results = ref.watch(searchResultsProvider(query));
    if (results.value case final found?) return SearchResultsView.found(_shown = found);
    if (results.isLoading) return SearchResultsView.searching(previous: _shown);
    return SearchResultsView.failed(results.error!);
  }
}
```

**The mechanism:**
- **Bloc** models typing as a stream of events and reshapes it. `switchMap` to a delayed value is the debounce, and `restartable()` cancels the running handler, so its `emit.isDone` turns true and its live results stop.
- **Riverpod** models each query as its own provider (a **family**):
  - the screen watches only the current query's provider;
  - when the user types on, the old one loses its last listener and is disposed;
  - `onDispose` cancels its timer, and the wait never completes.
  - The newest query wins because it's the only one still watched.
- **Live results:**
  - Bloc follows them with `emit.forEach` inside the handler.
  - Riverpod combines two stream providers with `ref.watch`; when either emits, `searchResults` rebuilds. No `stream_transform` or `rxdart` (an architecture test forbids them here).
- **The trap only Riverpod has:**
  - Riverpod 3 keeps a rebuilding provider's *previous* dependencies until its new build **completes**.
  - The first `CurrentSearchResults` was async, so it took the whole debounce to complete and kept every older query alive: "a", "ad" and "ada" were all searched.
  - It's now synchronous (conventions §11.109). Bloc has no equivalent, because `restartable()` cancels explicitly.

**Size:** the Bloc's event, state, transformer and Bloc files are 312 non-blank, non-comment lines. The Riverpod providers, state and debounce helper are 168. Most of the difference is the event classes and their handlers.

---

## 4. Settings: two scopes, one store

**Bloc** (`features/settings/cubit/settings_cubit.dart`, `di/app_module.dart`, `app/connect_hub_app.dart`):

```dart
@preResolve
@lazySingleton
Future<SharedPreferencesWithCache> get preferences =>
    SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: SettingsLocalDataSource.allowList));

@injectable
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(GetSettingsUseCase getSettings, WatchSettingsUseCase watchSettings,
      this._updateThemeMode, …) : super(getSettings()) {
    _subscription = watchSettings().listen((settings) { if (settings != state) emit(settings); });
  }
  Future<void> selectThemeMode(AppThemeMode mode) => _updateThemeMode(mode);
  …
}

MultiBlocProvider(
  providers: [BlocProvider(create: (_) => getIt<SettingsCubit>()), …],
  child: BlocSelector<SettingsCubit, AppSettings, AppThemeMode>(
    selector: (settings) => settings.themeMode,
    builder: (context, themeMode) => MaterialApp.router(themeMode: themeMode.toThemeMode(), …),
  ),
);
```

**Riverpod** (`main.dart`, `di/data_providers.dart`, `features/settings/settings_controller.dart`, `app/connect_hub_app.dart`):

```dart
// main.dart
final preferences = await SharedPreferencesWithCache.create(
  cacheOptions: const SharedPreferencesWithCacheOptions(allowList: SettingsRepositoryImpl.allowList));
runApp(ProviderScope(
  overrides: [preferencesStoreProvider.overrideWithValue(SharedPreferencesStore(preferences))],
  child: const ConnectHubApp(),
));

@Riverpod(keepAlive: true)
PreferencesStore preferencesStore(Ref ref) => throw UnimplementedError(
    'preferencesStoreProvider must be overridden before runApp (see main.dart)');

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  @override
  AppSettings build() => ref.read(getSettingsUseCaseProvider)();   // synchronous: no theme flash
  Future<void> setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    return ref.read(updateSettingsUseCaseProvider).themeMode(mode);
  }
}

// ConnectHubApp (a ConsumerWidget)
final themeMode = ref.watch(settingsControllerProvider.select((settings) => settings.themeMode));
```

**What changed:**
- **The async object before `runApp`:** injectable's `@preResolve` makes `getIt.init()` async. Riverpod has no async graph setup, so `main` awaits the store itself and injects it with the app's single override. The provider throws a clear error if anyone forgets.
- **App-wide vs screen-scoped:** both editions split the persisted preferences (app-wide) from the screen's actions (Clear cache, the developer switch):
  - in Bloc, an app-level `BlocProvider` and a `BlocProvider` in the Settings page;
  - in Riverpod, a `keepAlive` notifier and an auto-dispose one (`SettingsTools`).
- **One path for changes:** the Cubit re-emits from the repository's stream; the notifier sets `state` itself, then persists. Both are synchronous on the first frame.
- **A lint the Bloc edition can't have:** riverpod_lint's `only_use_keep_alive_inside_keep_alive` flagged the keepAlive notifier reading auto-dispose use cases, so those two are keepAlive too.

---

## 5. Dependency injection: a service locator vs a provider graph

| | get_it + injectable | Riverpod providers |
|---|---|---|
| Declaring | `@injectable` / `@lazySingleton` on the class (121 annotations) | a function per object (`di/data_providers.dart`, `di/use_case_providers.dart`, `core/network/network_providers.dart`: 384 lines) |
| Wiring | generated `injection.config.dart` | written by hand: `FeedRepositoryImpl(ref.watch(feedApiServiceProvider), …)` |
| Resolving | `getIt<FeedCubit>()` in Pages, the app and the router (19 files) | `ref.watch` / `ref.read` anywhere a `ref` exists |
| Lifetime | singleton / factory, chosen per class | keepAlive or auto-dispose, per provider; disposal is automatic |
| Parameters | `@factoryParam` (a post id) | families: `postDetailControllerProvider(postId)` |
| Async setup | `@preResolve` | `await` in `main` + `overrideWithValue` |
| Tests | `getIt.reset()`, register fakes, `tearDown` | `ProviderContainer.test(overrides: […])`, one graph per test, nothing global |
| Missing dependency | a runtime error at `getIt<T>()` | a compile error (a provider is a symbol you import) |

**Fair notes:**
- The Riverpod wiring is more code to write: every constructor call is explicit. injectable writes it for you from annotations.
- Riverpod's graph has no global state. Two tests (or two `ProviderScope`s) can't see each other's objects, and an override in one container reaches everything built on it there and nowhere else (`test/di/provider_graph_test.dart` checks this).
- In both, the domain and data classes are plain Dart with constructor parameters, and they don't know which DI is used.

---

## 6. Scoping and disposal

| Lifetime | Bloc | Riverpod |
|---|---|---|
| A screen | `BlocProvider(create:)` in its Page; closed with the route | auto-dispose: disposed when the last listener goes |
| One item (a post, a profile) | a Cubit per route, the id passed with `@factoryParam` | a family member per id; each disposed alone |
| The app | `BlocProvider` above `MaterialApp` | `keepAlive: true` |
| "Alive from launch" (the badge) | `BlocProvider` on the shell | a no-op `ref.listen` in the shell |

Auto-dispose is the default, so every `keepAlive` in this repo has a comment saying why ([PROVIDER_GRAPH.md](PROVIDER_GRAPH.md)).

---

## 7. Events vs methods, effects, streams

- **Events vs methods:**
  - ConnectHub-Flutter uses a Cubit by default (methods) and a Bloc where events earn their place: Search (debounce, restartable) and sign-in (droppable).
  - Riverpod notifiers only have methods. Concurrency is handled by disposal (Search), a guard (`if (state.isClearingCache) return;`), or the repository's lock (refresh and load-more take turns).
- **Effects:**
  - Bloc: `BlocListener` in the View, often with a `UiMessage` id so the same text can show twice.
  - Riverpod: `ref.listen` in the widget, then `messageShown()` to consume the message ([SIDE_EFFECTS.md](SIDE_EFFECTS.md)).
- **Streams:**
  - Bloc subscribes to repository streams (`listen`, `emit.forEach`, `combineLatest`).
  - Riverpod turns each stream into a provider, and combines them with `ref.watch`. A notifier `ref.listen`s a stream provider when a change should patch the state rather than re-run `build`.

---

## 8. Testing

**Bloc** (`test/features/feed/cubit/feed_cubit_test.dart`):

```dart
blocTest<FeedCubit, FeedState>(
  'a server with no posts: empty',
  setUp: () => feed.refreshResult = const Ok(false),
  build: buildCubit,
  act: (cubit) => cubit.load(),
  expect: () => [const FeedState.empty()],
);
```

**Riverpod** (`test/features/feed/feed_controller_test.dart`):

```dart
container = testContainer(overrides: [
  feedRepositoryProvider.overrideWithValue(feed),
  postRepositoryProvider.overrideWithValue(posts),
]);
container.listen(feedControllerProvider, (_, next) => states.add(describe(next)),
    fireImmediately: true);

test('cached posts show at once; the refresh behind them updates them', () async {
  start(cached: [p1, p2]);
  feed.refreshedWindow = [p3, p1, p2];
  await pumpEventQueue();
  expect(states, ['loading', 'data p1,p2', 'data p3,p1,p2']);
});
```

- **The same idea:** both record every state in order. Here the container plays `build:` and `container.listen` plays `expect:`. `describe` turns each `AsyncValue` into a short string, so a failure reads like a timeline.
- **Fakes, not mocks:** both repos use hand-written repository fakes. The Bloc edition also mocks Cubits (`MockCubit`) to test Views alone; this one overrides providers lower down, so widget tests run the real notifier.
- **Whole-app flows:** `pumpConnectHub(tester, overrides: realStack())`: the real graph over drift in memory and the fake server at latency 0. In the Bloc edition the same harness registers into `getIt` and resets it in `tearDown`.
- **Fake time:** `bloc_test` with `wait:`, or `fakeAsync`. Riverpod's rebuilds run on a scheduler tick, so `fakeAsync` tests need `elapse(Duration.zero)`, not just `flushMicrotasks` (§11.111).

---

## 9. Trade-offs

| | Bloc + get_it | Riverpod |
|---|---|---|
| Boilerplate | events, states and handlers; DI annotations, wiring generated | fewer classes per screen (Feed 178 → 144 lines, Search 312 → 168, Settings 115 → 74); DI wiring written by hand (384 lines) |
| Traceability | every change is an event or a method on one class; `BlocObserver` logs them all | changes flow through `ref.watch` edges; `ProviderObserver` logs updates, but *why* a provider rebuilt takes more reading |
| Compile-time safety | `getIt<T>()` fails at run time if `T` wasn't registered | a provider is a symbol: no "not registered" error. A required override (the preferences) still fails at run time, with a clear message |
| Concurrency | event transformers: `restartable`, `droppable`, `sequential` | disposal, guards, `ref.mounted`; no transformers |
| Lifetimes | explicit: whoever creates the Bloc closes it | automatic: auto-dispose, families, `keepAlive`; easy to get "disposed too early" wrong without a listener |
| Learning curve | small API, very explicit; more files | small API too, but rules to learn: `watch` vs `read` vs `listen`, previous dependencies kept until a rebuild completes, `ref` unusable after disposal |
| Lints | bloc_lint (optional) | riverpod_lint catches real mistakes (a keepAlive using an auto-dispose provider), but only under `dart analyze` |
| Team ergonomics | familiar from MVI / Redux; easy code review (one class per screen) | composition is powerful (a family per id, combining streams), but the graph is spread across many small providers |

**When to pick which:**
- **Bloc** when the team wants every change to be an explicit, loggable event; when concurrency rules are rich (sequential uploads, droppable submits); or when the team comes from MVI.
- **Riverpod** when much of the state is derived from other state (search over live results, a profile per id); when tests should swap any object without a global locator; and when one tool for DI and state is a plus.
- **This app** would be fine with either. The clearest wins here were Riverpod's families (post, profile, query) and debounce through disposal, and Bloc's explicitness in Search's concurrency.

---

## 10. The native editions

| Concept | Android ([ConnectHub-MVI](https://github.com/MuhammadFaheemAkram/ConnectHub-MVI)) | iOS ([ConnectHub-TCA](https://github.com/MuhammadFaheemAkram/ConnectHub-TCA)) | Flutter, Bloc | **Flutter, Riverpod** |
|---|---|---|---|---|
| Screen state | `ViewModel` + a reducer over `State` | `Reducer` + `@ObservableState` | `Cubit` / `Bloc` | **`Notifier` / `AsyncNotifier`** |
| User actions | `Intent`s | `Action`s | methods / events | **notifier methods** |
| Pure transitions | `reduce(state, intent)` | `Reduce` | in the Cubit | **in the notifier** (small pure helpers where it pays) |
| Effects | an `Effect` channel | `Effect` | `BlocListener` | **`ref.listen` + `messageShown()`** |
| Async work | `viewModelScope` | `.run` effects | `async` methods / handlers | **`async` methods, `ref.mounted`** |
| Cancellation | `flatMapLatest` | `.cancellable(id:)` | `restartable()` | **disposal** |
| DI | Hilt | `@Dependency` | get_it + injectable | **providers** |
| Test doubles | fakes via Hilt test modules | `withDependencies` | `getIt` registrations | **`overrides`** |
| Tests | reducer tests, Turbine | `TestStore` (exhaustive) | `bloc_test` | **`ProviderContainer.test` + every state recorded** |

**Riverpod is not MVI:**
- It has no single reducer and no action type: a notifier's methods change `state` directly.
- The closest it gets is "one notifier per screen, methods as intents, `state` as the single value the UI renders", which is what this repo does.
- TCA's exhaustive `TestStore` has no counterpart. Recording every state in order is the nearest habit.
