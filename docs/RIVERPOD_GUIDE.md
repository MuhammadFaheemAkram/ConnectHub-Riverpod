# Riverpod, as used in ConnectHub

A guide to the Riverpod 3 features this app uses, with the places to see each one. It assumes Flutter, not Riverpod. Versions: `flutter_riverpod` 3, `riverpod_annotation` 4, `riverpod_generator` 4, `riverpod_lint` 3.

---

## 1. Providers

A **provider** is a declared, lazily created value: an object (a repository), a stream (drift rows), a future, or a notifier with state. You declare it once, as a top-level function or class, and the generator writes the `…Provider` object you read it through.

```dart
// core/common/clock_provider.dart
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const Clock();            // → clockProvider

// di/data_providers.dart: a repository built from other providers
@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) => FeedRepositoryImpl(
  ref.watch(feedApiServiceProvider),
  ref.watch(appDatabaseProvider).feedDao,
);

// features/feed/feed_controller.dart: a stream
@riverpod
Stream<List<Post>> feedPosts(Ref ref) => ref.watch(watchFeedUseCaseProvider)();
```

- **Where they live:** a `ProviderScope` at the root (`main.dart`) holds every provider's current value. Nothing is global: tests make their own `ProviderContainer`.
- **The generator:** `@riverpod` + `part '….g.dart'` + `dart run build_runner build`. It infers the kind (plain, `Future`, `Stream`, notifier) from the return type.
- **Legacy providers** (`StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`) are not used; an architecture test forbids the `legacy.dart` import.

---

## 2. `ref`: watch, read, listen

| Call | Meaning | Use it in | Here |
|---|---|---|---|
| `ref.watch(p)` | read **and** rebuild me when `p` changes | `build` of providers and widgets | the app root watches the theme; `searchResults` watches two streams |
| `ref.read(p)` | read once, no subscription | methods, callbacks | `ref.read(likePostUseCaseProvider)(…)` in `toggleLike` |
| `ref.listen(p, cb)` | call `cb` on each change, without rebuilding | effects; patching a notifier's state | the Feed's SnackBar; `FeedController` patching posts from drift |
| `ref.invalidate(p)` | throw the value away; rebuild on next read | "Try again" | `ref.invalidate(feedControllerProvider)` |
| `ref.onDispose(cb)` | run `cb` when this provider is disposed | cleanup | `ref.debounce` cancels its timer; the database closes |
| `ref.mounted` | is this provider still alive? | after every `await` in a notifier | every controller |

**The two rules:**
- **`watch` in `build`, `read` in methods.** A `watch` in a method would subscribe at the wrong moment, and a `read` in `build` would miss changes.
- **`listen`, not `watch`, when a change should patch state rather than redo `build`.** `FeedController.build` refreshes from the server; if it *watched* the drift stream, every like would run that refresh again.

---

## 3. Notifiers

A **notifier** is a provider with state and methods: the screen's state holder (the Cubit's counterpart).

```dart
@riverpod
class CreatePostController extends _$CreatePostController {
  @override
  CreatePostState build() => const CreatePostState();      // Notifier: synchronous state

  void contentChanged(String value) => state = state.copyWith(content: value);
  …
}

@riverpod
class FeedController extends _$FeedController {
  @override
  Future<FeedState> build() async { … }                     // AsyncNotifier: AsyncValue<FeedState>

  Future<void> refresh() async { … state = AsyncData(…); }
}
```

- **`Notifier<T>`:** `build` returns `T`. Used for forms (`CreatePostController`), the search query, Settings (synchronous on purpose: no theme flash), and `CurrentSearchResults` (synchronous on purpose: §11.109).
- **`AsyncNotifier<T>`:** `build` returns `Future<T>`, and the state is an `AsyncValue<T>`. Used for every screen that loads: the feed, a post, notifications, profiles, saved posts.
- **Widgets call methods** through `ref.read(provider.notifier).method()`, and render `ref.watch(provider)`.
- **State is immutable** (freezed). A method assigns a new `state`; listeners are told when it changes (`==`).

---

## 4. `AsyncValue`

`AsyncLoading`, `AsyncData` and `AsyncError` describe a value that is loading, loaded or failed. They can also carry the *previous* value while reloading.

```dart
switch (feed) {
  AsyncValue(value: final state?) when state.posts.isEmpty => EmptyFeed(…),
  AsyncValue(value: final state?) => PostList(state: state, …),
  AsyncValue(isLoading: true) => const LoadingView(…),
  AsyncError(:final error) => ErrorView(…),
  _ => const LoadingView(…),
}
```

- **Data first:** a screen with data keeps it on screen whatever else is going on.
- **Loading before error:** after `ref.invalidate`, a failed provider stays an `AsyncError` with `isLoading: true` while it loads again. Check `isLoading` first, or "Try again" shows the error instead of a spinner.
- **A `throw` in `build`** becomes `AsyncError`. "Not found" is `AsyncError(NotFoundException())`, which the post and profile screens show as their own state.
- **No automatic retry:** Riverpod 3 retries a failing provider by default. This app turns it off (`ProviderScope(retry: noAutomaticRetry)`), because each screen offers "Try again".

---

## 5. Families

A **family** is a provider with a parameter: one instance per value, each cached and disposed on its own.

```dart
@riverpod
class PostDetailController extends _$PostDetailController {
  @override
  Future<PostDetailState> build(String postId) async { … }   // this.postId inside methods
}

ref.watch(postDetailControllerProvider('p1'));
```

| Family | Key | Why |
|---|---|---|
| `postDetailControllerProvider`, `cachedPostProvider`, `postCommentsProvider` | post id | one post per screen; two posts open → two controllers |
| `profileControllerProvider`, `cachedUserProvider`, `userPostsProvider` | user id | my Profile tab and `/users/u_ada` are two members |
| `searchHitsProvider`, `searchPeopleProvider`, `searchPostsProvider`, `searchResultsProvider` | the query | debounce through disposal (§7 below) |

The key must have value equality (`String` here).

---

## 6. Lifetimes: auto-dispose and `keepAlive`

- **Auto-dispose is the default** (`@riverpod`). A provider is disposed when nothing listens to it any more, and its `onDispose` callbacks run. Screens' controllers are auto-dispose, so leaving a screen frees it.
- **`@Riverpod(keepAlive: true)`** keeps the value for the container's lifetime:
  - app-wide objects (the database, repositories, the router, the fake server);
  - app-wide state: the settings, and the cache epoch.
- **A keepAlive provider may only use keepAlive providers** (riverpod_lint's `only_use_keep_alive_inside_keep_alive`). Otherwise it would keep an auto-dispose dependency alive by accident, or watch it be disposed. The two settings use cases are keepAlive for this reason.
- **Alive because of a listener:** the shell `ref.listen`s the notifications controller (an auto-dispose provider) with a no-op callback, so it's created at launch (the badge is right before the tab opens) and lives as long as the shell.

Every provider and its lifetime: [PROVIDER_GRAPH.md](PROVIDER_GRAPH.md).

---

## 7. Patterns built from these

- **Offline-first `build`:** read the cache; if it has data, return it and refresh behind it with `unawaited(Future(refresh))` (`Future(…)` waits until this build's state is in place). Otherwise wait for the server and `throw` on failure.
- **Debounce through disposal:** `await ref.debounce(300 ms)` inside a family keyed by the query. A disposed provider's timer is cancelled and the wait never completes (`core/common/debounce.dart`).
- **A synchronous provider between a changing input and a family:** Riverpod 3 keeps a rebuilding provider's *previous* dependencies until its new build completes, so an async provider in that spot keeps old family members alive (§11.109).
- **Reload many screens at once:** a keepAlive `Notifier<int>` epoch that each server-data controller `watch`es; Clear cache bumps it ([SIDE_EFFECTS.md](SIDE_EFFECTS.md)).
- **An object that needs an `await`:** a provider that throws unless overridden, and `overrideWithValue` in `main` after awaiting it (the preferences).
- **Reading providers outside widgets:** a go_router `redirect` uses `ProviderScope.containerOf(context, listen: false).read(…)`.

---

## 8. Testing with providers

```dart
final container = ProviderContainer.test(              // disposed after the test
  retry: noAutomaticRetry,
  overrides: [feedRepositoryProvider.overrideWithValue(FakeFeedRepository())],
);
container.listen(feedControllerProvider, (_, next) => states.add(describe(next)),
    fireImmediately: true);
```

- `overrideWithValue` replaces one provider, and everything built on it sees the replacement, in this container only.
- `realStack()` (`test/helpers/backend.dart`) overrides only the edges, so tests run the real graph: a fixed clock, seeded ids, latency 0, drift in memory, preferences in memory.
- Widget tests: `pumpConnectHub(tester, overrides: …)` wraps the app in a `ProviderScope`.

More in [TESTING.md](TESTING.md).

---

## 9. riverpod_lint

- It's an analyzer plugin (`plugins:` in `analysis_options.yaml`). It runs **only under `dart analyze` of the whole project**: `flutter analyze` and a subfolder skip it (§11.102), so CI runs `dart analyze --fatal-infos`.
- In this app it flagged a keepAlive notifier using auto-dispose providers. Its other rules include `missing_provider_scope`, `avoid_build_context_in_providers`, `avoid_public_notifier_properties`, `avoid_ref_inside_state_dispose`, `provider_parameters` (a family key needs value equality) and `async_value_nullable_pattern`.
