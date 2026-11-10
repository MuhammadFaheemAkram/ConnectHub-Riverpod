# Phase 2 — Feed Feature

## Phase Goal

Build the first real feature end to end, the Riverpod way:
- **the domain and data layers**, ported from ConnectHub-Flutter and trimmed to the feed:
  - the models, `Result` and `AppException`;
  - the fake server (seeded, with rebased times);
  - the simulated network and the feed API;
  - drift v1;
  - the repositories, with cursor paging and optimistic likes and saves.
- **the whole object graph as providers:** the database, the server, the API service, the repositories and the use cases. No service locator, nothing global;
- **the Feed screen, written fresh in Riverpod:**
  - `FeedController`, an `AsyncNotifier`, with loading, error and data from `AsyncValue`;
  - the cached posts at once, then refreshed;
  - pull to refresh, infinite scroll, likes and saves;
  - one-off SnackBars through `ref.listen`.

The point of the edition shows here: **the domain and data layers are ConnectHub-Flutter's** (the same classes, minus injectable's annotations), and **the presentation layer and the DI are new.** Every difference from the Bloc edition is a Riverpod difference.

---

## What Was Implemented

- **Domain** (`lib/domain/`):
  - `User` and `Post` (freezed);
  - the contracts `FeedRepository` (watch, refresh, load more) and `PostRepository` (like, save);
  - the use cases `WatchFeed`, `RefreshFeed`, `LoadMoreFeed`, `LikePost`, `SavePost`;
  - plain Dart: an architecture test keeps Flutter, Riverpod and the data layer out.
- **Common** (`lib/core/common/`):
  - `AppException` (network, not found, data format, unknown), `Result` (`Ok` / `Err`, Dart 3.13 primary constructors);
  - `RelativeTime`, `compactCount`, `firstValue`;
  - `clockProvider`.
- **The fake backend** (`lib/core/network/`):
  - **`FakeServer`**, trimmed from ConnectHub-Flutter's:
    - no accounts or tokens: the demo user `u_demo` is always signed in;
    - no chat;
    - the feed in cursor pages;
    - idempotent likes and bookmarks, per user;
    - comment counts derived from the seed's comments;
    - seed times rebased so the newest record is 5 minutes old.
  - `SeedLoader` (`auth_user.json`, `feed_posts.json`, `comments.json`), `AssetJsonLoader`;
  - `NetworkSimulator` (latency × factor, `failRequests`);
  - `FakeApiClient` (crosses the network, names the signed-in user);
  - `FeedApiService` and `FakeFeedApiService`; the DTOs;
  - **`network_providers.dart`:** the only way in.
- **drift v1** (`lib/core/database/`):
  - `users`, `posts`, `feed_items` (the feed window), `bookmarks`;
  - `PostsDao` (upserts, optimistic like and bookmark), `FeedDao` (the window: watch, replace, add);
  - the schema exported to `drift_schemas/`.
- **Data** (`lib/data/`):
  - `FeedRepositoryImpl` (cursor paging; refresh and load-more take turns);
  - `PostRepositoryImpl` (optimistic like and save with rollback, one request per post at a time);
  - `guardApiCall` (errors become `Result`s);
  - the mappers.
- **DI** (`lib/di/`):
  - `data_providers.dart`: the drift connection, the database, the repositories, `keepAlive`;
  - `use_case_providers.dart`: the use cases, auto-dispose.
- **The Feed** (`lib/features/feed/`):
  - `feedPostsProvider`: the drift stream as a provider;
  - `FeedController` (`AsyncNotifier<FeedState>`): build, `refresh`, `loadMore`, `toggleLike`, `toggleSave`, `messageShown`;
  - `FeedState` (freezed: the posts, `LoadMoreStatus` idle / loading / failed / done, a message);
  - `FeedPage` (a `ConsumerWidget`), `PostList` (infinite scroll, the footer), `EmptyFeed`;
  - the New post FAB shows "Creating posts arrives in Phase 3."
- **Design system:**
  - `PostCard` (Save / Unsave), `UserAvatar`;
  - `RelativeTimeText`, now a `ConsumerWidget` reading `clockProvider`.
- **Packages:**
  - runtime: `freezed_annotation`, `json_annotation`, `drift`, `drift_flutter`, `cached_network_image`, `clock`, `intl`, `synchronized`, `characters`;
  - dev: `freezed`, `json_serializable`, `drift_dev`, `fake_async`, `async`, `flutter_cache_manager`.
- **196 tests.**

---

## Riverpod Concepts Demonstrated

- **Providers are the DI.**
  - Each object is a function that builds it from the providers it watches:
    `feedRepository(ref) => FeedRepositoryImpl(ref.watch(feedApiServiceProvider), ref.watch(appDatabaseProvider).feedDao)`.
  - A missing dependency is a compile error, not get_it's runtime "not registered".
  - Interfaces are kept: `feedRepositoryProvider` is typed `FeedRepository`, so features depend on the contract.
- **`keepAlive` by decision, with a reason:**
  - the database (one connection; drift's change notifications need it);
  - the server (it holds the likes);
  - the simulator (it holds "Simulate network failure");
  - the repositories (they hold the cursor and the requests in flight).

  Use cases hold nothing, so they stay auto-dispose. A test shows an auto-dispose repository would forget where the next page starts.
- **`ref.onDispose`** closes the database with its container: the app's, or each test's.
- **Override the smallest thing.** The database's *connection* is a provider of its own (`databaseConnectionProvider`), and tests override only that, with an in-memory SQLite. The app's `appDatabaseProvider` (and its `onDispose`) then runs in every test. Overriding the whole database provider would have replaced the code under test with the test's copy of it (the mutation pass found exactly that; see *Notes*).
- **`AsyncNotifier`:** `build()` returns `Future<FeedState>`.
  - While it runs, the screen sees `AsyncLoading`.
  - If it throws (the first load failed with nothing cached), the screen sees `AsyncError`.
  - Otherwise it sees `AsyncData`.
  - "Empty" is data with no posts. ConnectHub-Flutter's `FeedState` needed four cases of its own; here `AsyncValue` already models three of them.
- **`ref.listen` inside a notifier, instead of `ref.watch`:**
  - the controller listens to `feedPostsProvider` and patches the posts in place;
  - watching would re-run `build` on every like, and with it the first load's refresh.
- **Intents are methods:** `refresh()`, `loadMore()`, `toggleLike(post)`, `toggleSave(post)`, called with `ref.read(feedControllerProvider.notifier)` in callbacks.
- **`ref.mounted` after every `await`:** a like that fails after the user left the Feed must not touch a disposed notifier (Riverpod 3 throws). A test holds the request until the controller is gone.
- **One-off effects through `ref.listen` + `select`:**
  - the page listens to `feedControllerProvider.select((feed) => feed.value?.message)`;
  - it shows the SnackBar and calls `messageShown()`;
  - clearing it makes the same failure, repeated, a change the page sees again (a test taps a failing Like twice).
- **Overrides as test seams, at three levels:**
  - `realStack()` swaps the clock, the latency and the database;
  - a fake repository replaces the data layer for controller and page tests;
  - a wrapped API service holds requests in flight.

  Each override belongs to one container, so there's nothing to reset between tests.
- **A widget reading a provider:** `RelativeTimeText` reads `clockProvider`, the same clock as the server and repositories. ConnectHub-Flutter's widget used the zone's `clock`, because a widget couldn't reach get_it's container.

---

## Flutter / Dart Concepts Demonstrated

- **The event loop, used deliberately:**
  - with posts cached, `build` returns them and starts the refresh with `Future(refresh)`;
  - that runs on the *next* event-loop turn, after Riverpod has stored the build's state, so the refresh's outcome (the footer's `done`, a failure's message) has a state to update.
- **drift streams lag their writes** (conventions §11.3): after a refresh, the controller reads the cache directly (`firstValue`) instead of waiting for the stream, so the posts and the footer change together. A flow test records every state of a first launch: `loading`, then six posts, never an empty feed in between.
- **The infinite list:** a `ScrollController` plus `ScrollMetricsNotification` (a short list that fits on screen keeps loading).

---

## Provider Graph & State Flow

```
FeedPage
  └─ feedControllerProvider          auto-dispose   AsyncNotifier<FeedState>
       ├─ listen feedPostsProvider    auto-dispose   Stream<List<Post>> (drift)
       └─ read  …UseCaseProviders     auto-dispose   watchFeed · refreshFeed · loadMoreFeed · likePost · savePost
            ├─ feedRepositoryProvider keepAlive      cursor + lock
            └─ postRepositoryProvider keepAlive      requests in flight
                 ├─ feedApiServiceProvider           keepAlive   FakeFeedApiService
                 │    └─ fakeApiClientProvider       keepAlive
                 │         ├─ networkSimulatorProvider  keepAlive   latency · failRequests
                 │         └─ fakeServerProvider        keepAlive   seed (assetBundleProvider) · clockProvider
                 ├─ appDatabaseProvider              keepAlive   onDispose: close
                 │    └─ databaseConnectionProvider  keepAlive   a file (tests: in memory)
                 └─ clockProvider                    keepAlive
```

**State flow, a first launch with nothing cached:**

```
FeedPage watches → build(): listen(feedPosts); cache empty
  → AsyncLoading ─ RefreshFeedUseCase → FeedRepository → API → drift (replace window)
  → read the cache → AsyncData(FeedState(posts: 6, loadMore: idle))
```

**A like:**

```
tap ♥ → controller.toggleLike(post) → LikePostUseCase → PostRepository
  → drift: isLiked, count + 1 ─(stream)→ feedPosts → listener → posts patched → card shows ♥ 143
  → API ok: the server's count written │ API failed: rolled back, Err
  → (Err) state.message = "Couldn't update the like…" → ref.listen → SnackBar → messageShown()
```

**Load more:** `PostList` nears the end, then `loadMore()`:
- idle → loading → idle (the page appended) or done (the last page) or failed (Retry).

### The Feed with Bloc (ConnectHub-Flutter) and with Riverpod

| | ConnectHub-Flutter (`FeedCubit`) | ConnectHub Riverpod (`FeedController`) |
|---|---|---|
| Created by | `BlocProvider(create: (_) => getIt<FeedCubit>()..load())` | the first `ref.watch(feedControllerProvider)` |
| Dependencies | six constructor parameters, injected by get_it | `ref.read(…UseCaseProvider)` where used |
| State | a sealed `FeedState`: loading / empty / error / loaded | `AsyncValue<FeedState>`; `FeedState` is only the data |
| The cache stream | `StreamSubscription` in the constructor, cancelled in `close()` | `ref.listen(feedPostsProvider)`, removed automatically on dispose |
| "Try again" | `cubit.load()` | `ref.invalidate(feedControllerProvider)`: `build` runs again |
| After an await | `if (isClosed) return;` | `if (!ref.mounted) return;` |
| A one-off SnackBar | `UiMessage` with an id, `BlocListener(listenWhen: …)` | a message consumed by `messageShown()`, `ref.listen(…select(…))` |
| Lines (logic + state + page + widgets) | 187 + 33 + 37 + 305 = 562 | 160 + 37 + 92 + 197 = 486 |

---

## Data Flow

```
FeedPage ─watch─▶ FeedController ─read─▶ UseCase ─▶ FeedRepository / PostRepository
   ▲                   ▲                                   │            │
   │                   └─ listen ─ feedPostsProvider ◀─ drift streams ◀─┤ (offline-first)
   └──── AsyncValue<FeedState> ◀──────────────────────────────────────┘
                                         FeedApiService ─▶ FakeApiClient ─▶ NetworkSimulator ─▶ FakeServer
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `lib/core/network/network_providers.dart` | The fake backend as `keepAlive` providers; the only way in |
| `lib/core/network/fake_server/fake_server.dart` | The trimmed fake server: feed pages, likes, bookmarks |
| `lib/core/network/api/fake_feed_api_service.dart` | The feed endpoints over the server |
| `lib/core/database/app_database.dart` (+ `tables/`, `daos/`) | drift v1 |
| `drift_schemas/app_database/drift_schema_v1.json` | The exported schema, for migration tests from Phase 3 |
| `lib/data/repository/feed_repository_impl.dart`, `post_repository_impl.dart`, `api_guard.dart` | Offline-first feed, optimistic writes, errors as `Result`s |
| `lib/di/data_providers.dart`, `use_case_providers.dart` | The graph |
| `lib/features/feed/feed_controller.dart` (+ `.g.dart`) | `feedPostsProvider` and `FeedController` |
| `lib/features/feed/feed_state.dart` (+ `.freezed.dart`) | The Feed's data and `LoadMoreStatus` |
| `lib/features/feed/feed_page.dart`, `widgets/` | The screen |
| `test/helpers/backend.dart` | `realStack()` (fixed clock, no latency, an in-memory connection), `testContainer()` |
| `test/helpers/data_stack.dart` | The real data stack, built by the app's providers |
| `test/features/feed/feed_controller_test.dart` | Every state of the controller, in order |
| `test/features/feed/feed_page_test.dart`, `feed_flow_test.dart` | The page in each state; flows on the real graph |
| `test/di/provider_graph_test.dart` | The graph resolves; overrides reach everything; lifetimes |

---

## Important Types Added

| Type | Responsibility | Layer / why there |
|---|---|---|
| `Post`, `User` | What screens show | `domain/model`: plain data |
| `FeedRepository`, `PostRepository` | The contracts features depend on | `domain/repository` |
| `WatchFeedUseCase` … `SavePostUseCase` | One action each | `domain/usecase`: plain classes; providers in `di/` |
| `FeedRepositoryImpl`, `PostRepositoryImpl` | Offline-first, optimistic | `data/repository` |
| `FakeServer`, `NetworkSimulator`, `FakeApiClient`, `FakeFeedApiService` | The backend and the wire | `core/network`: reached only through providers |
| `AppDatabase`, `PostsDao`, `FeedDao` | The cache | `core/database` |
| `FeedController` | The Feed's state and intents | `features/feed`: presentation |
| `FeedState`, `LoadMoreStatus` | The Feed's data | `features/feed` |
| `PostList`, `EmptyFeed` | The Feed's widgets | `features/feed/widgets` |
| `PostCard`, `UserAvatar`, `RelativeTimeText` | Shared widgets | `core/design_system` |

---

## Folder Structure Changes

```
ConnectHubRiverpod/
├── assets/json/                 auth_user.json, feed_posts.json, comments.json
├── drift_schemas/app_database/  drift_schema_v1.json
├── lib/
│   ├── core/common/             app_exception, result, relative_time, compact_count, first_value, clock_provider
│   ├── core/network/            network_providers, asset_json_loader, api/, dto/, fake_server/
│   ├── core/database/           app_database, tables/, daos/
│   ├── data/                    mapper/, repository/
│   ├── domain/                  model/, repository/, usecase/
│   ├── di/                      data_providers, use_case_providers
│   └── features/feed/           feed_controller, feed_state, feed_page, widgets/
└── test/
    ├── flutter_test_config.dart  images load offline
    ├── helpers/                  backend, data_stack, fixtures, database_rows, fakes/
    ├── core/ data/ di/ features/feed/
    └── …
```

---

## Android / iOS Comparison

| Concept | Android (MVI) | iOS (TCA) | Flutter (Bloc) | **Flutter (Riverpod)** |
|---|---|---|---|---|
| Screen state | `FeedViewModel` + reducer, `StateFlow<FeedState>` | `FeedFeature` reducer, `State` | `FeedCubit`, a sealed `FeedState` | **`FeedController`, `AsyncValue<FeedState>`** |
| Intents | `FeedIntent.LikePost(id)` | `Action.likeTapped(id)` | Cubit methods | **notifier methods** |
| Effects | a `Channel<FeedEffect>` | `Effect` | `UiMessage` + `BlocListener` | **a consumed message + `ref.listen`** |
| The cache stream | Room `Flow` collected in the ViewModel | SwiftData `@Query` / a client stream | a `StreamSubscription` | **a `StreamProvider`, `ref.listen`** |
| DI | Hilt modules | `@Dependency(\.feedClient)` | get_it + injectable | **providers** |
| Paging | Paging 3 / a cursor | a cursor | a cursor in the repository | **the same repository** |
| Optimistic like | in the repository | in the reducer + effect | in the repository | **in the repository** |

---

## Interview Notes

- **"How do you do dependency injection with Riverpod?"**
  - Each dependency is a provider that builds it from the providers it watches.
  - App-lifetime objects are `keepAlive`.
  - Tests replace any provider with `overrides` on their own container.
  - There's no registration step and no global locator to reset.
- **"Why `ref.listen` and not `ref.watch` inside your notifier?"**
  - `watch` re-runs `build` when the watched provider changes. The feed's cache changes on every like, and `build` runs the first load's refresh.
  - `listen` patches the posts in place.
- **"How does a notifier avoid touching state after it's disposed?"**
  - `if (!ref.mounted) return;` after every `await`.
  - Riverpod 3 throws otherwise, and a test proves the check is needed.
- **"How do you show a SnackBar from a notifier?"**
  - You don't: the notifier puts a message in its state, and the page shows it from `ref.listen` (never in `build`), then tells the notifier it was shown.
  - Clearing it lets the same message show again.
- **"Where do optimistic updates live?"**
  - In the repository: drift first, then the API, then reconcile or roll back.
  - Every screen watching that row updates, and the notifier only reports a failure.
- **"What does 'Try again' do?"** `ref.invalidate(feedControllerProvider)`: it throws the failed state away and runs `build` again. Nothing is retried automatically.

---

## Learning Checklist

- ✅ The object graph as providers, `keepAlive` justified, closed with `ref.onDispose`
- ✅ `AsyncNotifier` with `AsyncValue` for loading, error and data
- ✅ A drift stream as a provider, combined with `ref.listen`
- ✅ Intents as notifier methods; `ref.mounted` after every await
- ✅ One-off effects via `ref.listen` + `select`, consumed once
- ✅ Offline-first, cursor paging, optimistic writes with rollback
- ✅ Notifier tests without widgets; page tests with overridden repositories; flows on the real graph
- □ Families (Phase 3: a post by id)
- □ Debounce through disposal (Phase 4)

---

## Future Improvements

- Phase 3 opens posts (a family by post id), adds comments (drift v2) and Create Post (the FAB).
- The images come from the network (`cached_network_image`): offline they fall back to initials and a plain box.
- Clear cache (Phase 5) will need the feed to load again; ConnectHub-Flutter did that with a "cache cleared" stream, and Riverpod can `ref.invalidate` the controller instead.

---

## Notes on This Phase

- **Riverpod behaviour found along the way:**
  - **"Try again" stays an `AsyncError`.** After `ref.invalidate`, a provider that had failed stays an `AsyncError` with `isLoading: true` while it builds again; it doesn't become an `AsyncLoading`. A `switch` that matches `AsyncError` first keeps the error on screen during the retry. The page checks `isLoading` before the error. A page test and the controller test both pin it.
  - **`future` inside `build` flushes the element.** `AsyncNotifier.future` calls `flush()`, which is not something to do from inside the build. Hence `Future(refresh)` (see *Flutter / Dart Concepts*) instead of awaiting `future` before refreshing.
  - **Notifiers survive rebuilds.** In Riverpod 3 a notifier's fields are kept across rebuilds; the CHANGELOG shows this was briefly changed and reverted. This controller keeps no fields anyway.
- **The seed's newest record is now a comment** (c13): notifications arrive in Phase 4. So p1 is 2h15m older than "five minutes ago" here; in ConnectHub-Flutter it was 2h55m. The rebase test documents both.
- **`main()` in a test:** the real app opens its database on disk and waits out real latencies. The `main` test checks the scope after one frame, then unmounts the app and lets the simulated requests land.
- **Builds:** the Android debug APK and the iOS simulator app.
- **On the iPhone 17 Pro simulator:**
  - the feed loaded from the fake server, with images and avatars;
  - "2h" and "3h" from the rebased seed;
  - a Like turned the heart red and the count to 143 at once;
  - light and dark checked; the appearance, text size and status bar restored afterwards.
- **Mutation checks:** 43 rules broken on purpose, one at a time, each against the tests that should catch it. **All 43 caught**, three after new tests or a better seam:

| Area | Mutations | Notes |
|---|---:|---|
| Fake server and network | 8 | The cursor's tie-break; likes counted; a save keeps its first time; the rebase; comment counts; the last page's cursor; simulated failures; the latency factor |
| drift | 6 | REPLACE instead of an upsert; the feed's order; a refresh that appends; the optimistic count; a bookmark for an uncached post; foreign keys |
| Repositories | 8 | The cursor reset; no request past the end; the lock; rollback; the server's count and time; one request at a time; the guard keeping the app's error |
| Providers | 3 | The feed repository kept alive (regenerated); the database closed with its container; the widget's time from the clock provider |
| FeedController | 11 | Live updates; the refresh behind the cache (missing, and started at once); the first load's failure, fresh cache and empty-feed error; `ref.mounted`; load more while loading and after done; the message cleared; save's direction |
| The page and widgets | 7 | The message consumed; the spinner on "Try again"; "Try again" invalidating; a failed page not retried in a loop; save's labels; the use case's direction; a widget importing the data layer |

- **The three that survived at first:**
  - **The cursor's tie-break:** no two seed posts share a time, so nothing exercised it. A test now seeds three posts at one instant and pages them one by one.
  - **The database not closed:** the tests overrode the whole database provider with their own (which closed its database), so the app's provider never ran in a test. Now tests override only the connection.
  - **Starting the refresh at once instead of with `Future(refresh)`:** it only matters when the refresh comes back without ever yielding. A test whose fake answers with a `SynchronousFuture` shows the failure's message being lost; with `Future(refresh)` it is shown. (ConnectHub-Flutter had the same regression test: "however fast it fails".)
