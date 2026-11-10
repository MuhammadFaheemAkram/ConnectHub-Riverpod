# Architecture

ConnectHub Riverpod keeps [ConnectHub-Flutter](https://github.com/MuhammadFaheemAkram/ConnectHub-Flutter)'s **layered clean architecture**, with Riverpod for both the presentation layer and the dependency injection. Data flows one way:
- widgets call notifier methods;
- immutable state flows back through `ref.watch`;
- screens read only the local cache.

```
┌──────────────────────────────── presentation (features/) ─────────────────────────────────┐
│  ConsumerWidget ─ref.watch / ref.listen─▶ Notifier / AsyncNotifier (auto-dispose, families)│
└──────────────────────────────────────────────┬─────────────────────────────────────────────┘
                                               │ use-case providers (di/use_case_providers.dart)
┌──────────────────────────────────────────────▼─────────────────────────────────────────────┐
│  domain/ (pure Dart)  User · Post · Comment · AppNotification · SearchHits · AppSettings ·  │
│                       Result-returning repository contracts · use cases                     │
└──────────────────────────────────────────────┬─────────────────────────────────────────────┘
                                               │ implemented by (di/data_providers.dart)
┌──────────────────────────────────────────────▼─────────────────────────────────────────────┐
│  data/  repositories (+ guardApiCall) · mappers                                              │
└────────┬───────────────────────────────┬──────────────────────────┬─────────────────────────┘
         │ core/network                  │ core/database            │ core/storage · core/platform
         ▼                               ▼                          ▼
  API services ─▶ FakeServer       drift (SQLite): the cache    SharedPreferencesWithCache
  (in memory, seeded from          connect_hub.sqlite           dynamic_color · package_info_plus
   assets/json)
```

**The everyday data flow:**

```
Widget ─ref.read(p.notifier).like(post)─▶ Notifier ─▶ UseCase ─▶ Repository ─┬─ write ─▶ drift (at once) ─┐
                                                                              └─ ApiService ─▶ FakeServer   │
Widget ◀── ref.watch(p) ◀── state ◀── Notifier ◀── ref.listen(streamProvider) ◀── drift .watch() ◀─────────┘
```

---

## Layers and their rules

| Layer | Contains | May import | Must not import |
|---|---|---|---|
| `domain/` | entities (freezed), repository contracts, use cases | `core/common` (`Result`, `AppException`) | Flutter, Riverpod, drift, JSON, `data/` |
| `data/` | repository implementations, `guardApiCall`, mappers | `domain/`, `core/*` | features |
| `core/network` | API contracts, fake services, `FakeApiClient`, `FakeServer`, DTOs, `network_providers.dart` | `core/common`, JSON packages | `material_ui`, drift |
| `core/database` | `AppDatabase`, tables, DAOs, migration steps | drift | `material_ui`, JSON packages |
| `core/storage` | `PreferencesStore` (over `SharedPreferencesWithCache`) | `shared_preferences` | everything above it |
| `core/platform` | wallpaper colors, the app's version | `dynamic_color`, `package_info_plus` | everything above it |
| `core/design_system` | themes, tokens, shared widgets, the large-text rule | `material_ui`, `domain/model` | features, routes |
| `core/navigation` | typed routes, the router provider | features' pages | |
| `di/` | providers for storage, repositories, use cases; the cache epoch | everything below features | features |
| `features/<feature>` | page, notifier(s), state, widgets | `domain/`, `di/`, design system, routes | `data/`, `core/network`, `core/database` |

`test/architecture/architecture_test.dart` enforces these:
- the domain is plain Dart;
- only `core/network/` knows the fake server;
- widgets never reach the data layer;
- drift files import no UI or JSON packages;
- platform packages stay behind their seams;
- Material comes from `material_ui`;
- no legacy providers, no `get_it` or Bloc, no stream library;
- one `ProviderScope`, in `main.dart`.

---

## Who owns what

| Data | Source of truth | Client copy | Notes |
|---|---|---|---|
| users, posts, likes, saves, comments, comment likes | the fake server | drift | a refresh mirrors the server (upsert, and delete what's gone) |
| notifications and their read state | the fake server | drift | the read state is the server's, so a refresh never resets it |
| the feed window (which posts, in which order) | the client | drift (`feed_items`) | a refresh replaces it; load-more appends after a cursor |
| recent searches | the client | drift | saved only on intent (the search key, opening a result) |
| settings | the client | `SharedPreferencesWithCache` | three keys, read synchronously |
| "Simulate network failure" | the client | memory | resets on restart |

---

## State management

- **One notifier per screen:** `FeedController`, `PostDetailController(postId)`, `CreatePostController`, `SearchQueryController` + `CurrentSearchResults`, `NotificationsController`, `ProfileController(userId)` + `SavedPostsController`, `SettingsController` + `SettingsTools`.
- **`AsyncNotifier` for screens that load:** loading and error come from `AsyncValue`; the state holds only data (and a one-off `message`).
- **`Notifier` when the state is ready at once:** forms, the search query and results view, the settings.
- **Streams as providers:** each drift query is a stream provider (`feedPostsProvider`, `cachedPostProvider(id)`, …). Notifiers `ref.listen` them to patch their state; derived providers `ref.watch` them to rebuild.
- **Auto-dispose by default;** `keepAlive` only for app-wide objects and state, each with a comment. Every provider and its lifetime: [PROVIDER_GRAPH.md](PROVIDER_GRAPH.md).
- **Effects** (SnackBars, clearing a field, closing a form) are values in state that widgets `ref.listen` to and consume: [SIDE_EFFECTS.md](SIDE_EFFECTS.md).

### How a list screen decides what to show

```
build(): cached?  yes → return it; refresh behind it (Future(refresh))
                  no  → wait for the server → data, or throw → AsyncError ("Try again")
widget:  data (empty → the empty state; else the list) → loading → error
refresh failure with data on screen → the data stays + a SnackBar
```

---

## Error handling

- **API calls** go through `guardApiCall`: an `AppException` becomes `Err(exception)`; any other `Exception` is logged and becomes `UnknownException`; `Error`s propagate.
- **Repositories** return `Result`, never throw.
- **Notifiers:**
  - a failed first load `throw`s, so `build` ends in `AsyncError`;
  - a failed refresh, like or save sets a `message`;
  - a 404 is `AsyncError(NotFoundException())`, shown as its own state ("This post is no longer available.", "This profile isn't available.").
- **No automatic retry** (`ProviderScope(retry: noAutomaticRetry)`): the UI offers "Try again" (`ref.invalidate`).

---

## Writes: optimistic, ordered, exact

- Likes, saves, comment likes, deleted comments and read notifications change drift first, then ask the server.
- If the server refuses, the repository puts back exactly the row it replaced, and the notifier shows a message.
- Two likes or saves of the same post take turns (`PostRepositoryImpl._oneAtATime`), and refresh and load-more take turns on the feed window (a `Lock`).

---

## Navigation

- **go_router with typed routes** (`go_router_builder`), the router itself a keepAlive provider (`appRouterProvider`).
- **Tabs:** a `StatefulShellRoute.indexedStack` with four branches (`/feed`, `/search`, `/notifications`, `/profile`), each with its own Navigator, kept alive offstage.
- **Root-level screens:** `/posts/:postId`, `/users/:userId`, `/compose` (a full-screen dialog) and `/settings` are pushed above the tab bar; unknown paths get a not-found page.
- **My profile is a tab:**
  - `/users/<my id>` redirects to `/profile`; the redirect reads `signedInUserIdProvider` through `ProviderScope.containerOf`;
  - `openProfile` switches tabs for my id and pushes everyone else's.

---

## Dependency injection

Providers. There is no service locator:
- every object is declared once, as a provider, and built from other providers with `ref.watch`;
- tests replace any of them with `overrides` in their own `ProviderContainer`.

| What | Lifetime | Where |
|---|---|---|
| the fake server, simulator, client and services | keepAlive | `core/network/network_providers.dart` |
| the database, the preferences store, repositories, the cache epoch | keepAlive | `di/data_providers.dart` |
| use cases | auto-dispose (the two settings ones keepAlive) | `di/use_case_providers.dart` |
| screens' notifiers and stream providers | auto-dispose; families by id | `features/*/…_controller.dart` |
| the preferences | overridden in `main` with the opened store | `main.dart` |

The contrast with get_it + injectable is in [BLOC_VS_RIVERPOD.md](BLOC_VS_RIVERPOD.md#5-dependency-injection-a-service-locator-vs-a-provider-graph).

---

## Persistence

- **drift v3** (`connect_hub.sqlite`), foreign keys on:
  - `users`;
  - `posts` (→ `users`), `feed_items` (→ `posts`), `bookmarks` (→ `posts`);
  - `comments` (→ `posts`, cascade; with `like_count`, `is_liked`) (v2);
  - `recent_searches`, `notifications` (v3).
- **Writes are upserts** (`insertOnConflictUpdate`), never `REPLACE`: a `REPLACE` deletes the row first, and the delete would cascade.
- **Migrations** are generated (`make-migrations`), each schema version is exported to `drift_schemas/`, and every upgrade path is tested, with data tests for v1 → v2 and v2 → v3.
- **Clear cache** (`CacheDao.clearServerData`) deletes the server's data but keeps saved posts, their authors, the demo user and recent searches.
- **Preferences:** `SharedPreferencesWithCache` with an allow-list of three keys (theme mode, wallpaper colors, unread badge), opened before `runApp`.

---

## Accessibility

- Every icon button has a tooltip (its screen-reader label); counts read as words ("128 Followers"); unread notifications announce "Unread. Like.".
- Tap targets are at least 48 × 48.
- **Large text:**
  - text grows with the user's setting everywhere;
  - side-by-side controls stack above 130 % (`prefersStackedLayout`): Settings' Appearance becomes a radio list, profile counts wrap.
- Colours meet WCAG AA in both themes. `test/app/accessibility_tour_test.dart` tours every screen and state at 200 % text in light and dark, with Flutter's tap-target, label and contrast guidelines.

---

## Key decisions

| Decision | Alternative | Why |
|---|---|---|
| Riverpod for state *and* DI | Riverpod + get_it | one graph; overrides reach everything in tests; no global state |
| Code generation (`@riverpod`) | hand-written providers | the kind and lifetime come from the declaration; families get typed parameters |
| Auto-dispose by default | keepAlive by default | screens free their state; keepAlive is a visible, justified exception |
| Debounce through disposal | a stream transformer | the family per query already exists; disposal cancels for free |
| A synchronous `CurrentSearchResults` | an async provider | Riverpod 3 keeps old dependencies until a rebuild completes (§11.109) |
| An epoch provider for Clear cache | a "cleared" stream per screen | one `ref.watch` line per screen |
| The preferences overridden in `main` | an async settings provider | synchronous settings: no theme flash |
| Retry off app-wide | Riverpod's default retry | screens offer "Try again"; a retry loop would hide errors behind a spinner |
| An in-memory `FakeServer` behind API interfaces | fake repositories | the data layer is real; only the services would change for a real backend |
| Screens read only drift | screens holding network results | offline-first, one source of truth, every screen consistent |
| Generated files committed | generating in CI | clone-and-run; CI fails if they're stale |
