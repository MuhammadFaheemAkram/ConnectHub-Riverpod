# Phase 4 — Search + Notifications

## Phase Goal

Two features that each teach one Riverpod idea:
- **Search, debounced through disposal.**
  - Each query is its own provider (a family), and it waits 300 ms before asking the server.
  - Typing on moves the screen to the next query's provider, so the old one is disposed and its wait cancelled. The newest query wins because it's the only one still watched; there's no `restartable()` and no stream library.
  - The results are live (a like anywhere shows in them), the previous results stay while the next query loads, and recent searches are saved on intent only.
- **Notifications, with a tab badge from launch:**
  - All / Unread, mark one read, mark all read; the read state is the server's;
  - the shell keeps the notifications controller alive with a `ref.listen`, so the badge is right before the tab is ever opened.

And **drift v3** (recent searches, notifications), with its migration tested on data.

---

## What Was Implemented

- **Fake server:**
  - `search` (people by name or bio, never the viewer, the most followed first; posts by content or author, newest first);
  - notifications (the seed's eight, newest first; mark one read, only your own, or a 404; mark all read).
  - The seed now includes `notifications.json`, so the newest seed record is notification n1. Every seed time moved by 40 minutes: p1 is 3h old instead of 2h, and the tests say so.
- **APIs:** `SearchApiService`, `NotificationApiService`, their fakes and providers; the DTOs.
- **drift v3:**
  - `recent_searches` (keyed by the trimmed, lower-case query; at most 10; newest first);
  - `notifications` (the server's read state; links to a post or a user);
  - `SearchDao` (caches results without touching the feed; reads people and posts back by id);
  - `NotificationsDao` (mirror, the unread `COUNT`, optimistic read and all-read with exact rollback);
  - `make-migrations` (v3 schema, steps, snapshot) and a v2 → v3 data test.
- **Domain and data:**
  - `SearchHits`, `SearchResults`, `SearchScope`, `AppNotification`;
  - `SearchRepository` (search, then `watchPeople` / `watchPosts` by id: **two streams**, combined by a provider);
  - `NotificationRepository`; eleven use cases.
- **`ref.debounce(duration)`** (`core/common/debounce.dart`): waits, unless the provider is disposed first. Then the timer is cancelled and the wait never ends.
- **Search** (`features/search/`):
  - `searchHitsProvider(query)` (debounced, then the server);
  - `searchPeopleProvider(query)` and `searchPostsProvider(query)` (live from drift);
  - `searchResultsProvider(query)` (the two, combined with `ref.watch`);
  - `CurrentSearchResults` (a **synchronous** `Notifier`: idle, searching with the previous results, found, failed);
  - `recentSearchesProvider`;
  - `SearchQueryController` (query, scope, recent searches, likes and saves in the results);
  - `SearchPage`:
    - `AppSearchField` with a Clear button (Material's `SearchBar` adds an unlabelled tappable surface; see *Notes*);
    - the All / People / Posts chips; recent searches with "Clear history";
    - People and Posts sections, "No results", the error with "Try again".
- **Notifications** (`features/notifications/`):
  - `cachedNotificationsProvider`, `unreadNotificationCountProvider`;
  - `NotificationsController` (an `AsyncNotifier`: cached then refreshed, the filter, mark read, mark all, effects);
  - `NotificationsPage`:
    - the chips; `NotificationTile` (unread: bold, a dot, the `unread` tint);
    - tapping one marks it read and opens its post or profile;
    - "Mark all read" while anything is unread;
    - "No notifications yet" / "Nothing unread.", pull to refresh.
- **The shell:** a `ConsumerWidget` with `UnreadBadge` on Notifications.
- **`/users/:userId`:** a placeholder profile page, so people in the results and follow notifications open somewhere until Phase 5.
- **433 tests.**

---

## Riverpod Concepts Demonstrated

- **Debounce through disposal:**
  ```dart
  @riverpod
  Future<SearchHits> searchHits(Ref ref, String query) async {
    await ref.debounce(searchDebounce);   // cancelled if this provider is disposed
    return switch (await ref.read(searchUseCaseProvider)(query)) { … };
  }
  ```
  The family key is the trimmed query. A test types "a", "ad", "ada" 100 ms apart and sees one search ("ada"), with "a" and "ad" disposed and no timer left.
- **A Riverpod 3 rule that shaped the design:**
  - when a provider rebuilds, Riverpod pauses its previous dependencies and keeps them until the new build *completes*;
  - the first version watched the query from an **async** provider, which took the whole debounce to complete and so kept every query typed meanwhile alive: all three were searched (found by the test above);
  - `CurrentSearchResults` is now **synchronous**, so its build completes at once and lets go of the old query immediately.
- **No flicker without `copyWithPrevious`:**
  - the synchronous notifier keeps the last results it showed in a field (a notifier's fields survive its rebuilds);
  - while the next query waits, it returns `searching(previous: …)`, and the page shows them under a progress bar;
  - `AsyncValue.copyWithPrevious` would do this, but it's internal in Riverpod 3.
- **Combining streams with `ref.watch`:** `searchResultsProvider(query)` awaits `searchPeopleProvider(query).future` and `searchPostsProvider(query).future`. When either drift query emits (a like on another screen), it rebuilds. ConnectHub-Flutter merged the two streams with `combineLatest`. An architecture test now forbids `stream_transform` and `rxdart`.
- **Keeping a provider alive from a widget:** `ref.listen(notificationsControllerProvider, (_, _) {})` in the shell. It's a listener with nothing to do, but it means the controller is created at launch (and the badge filled) and lives as long as the shell. `keepAlive` would have kept it for the app's lifetime, which is less precise.
- **A badge from a `COUNT` query:** `unreadNotificationCountProvider` emits a number, so the shell rebuilds only when the count changes, not on every notification change.
- **`select` for an app bar button:** `notificationsControllerProvider.select((state) => state.value?.hasUnread ?? false)`. "Mark all read" rebuilds when "anything unread?" flips, not for every row.

---

## Flutter / Dart Concepts Demonstrated

- **A wait that never ends, on purpose:**
  - the first `debounce` completed a cancelled wait with an error;
  - by then the provider was gone, so nothing handled the error, and tests failed with it uncaught;
  - an abandoned future that never completes is simply collected.
- **Fake time and Riverpod:**
  - search tests run in `fakeAsync` with a fake repository (no drift: fake time and drift don't mix, §11.27);
  - this container's rebuilds run on a scheduler tick, so tests `elapse(Duration.zero)` rather than only flushing microtasks.
- **Two traps in widget tests:**
  - awaiting a stream's `.first` inside a widget test's fake time hung (the fake now exposes a plain getter);
  - a tap below the phone-height surface missed silently (§11.51), so the flow scrolls to it first.
- **`Wrap` instead of `Row`:** "Recent searches" + "Clear history" overflowed at 200 % text (found by the tour). A `Wrap` moves the button under the title.

---

## Provider Graph & State Flow

```
SearchPage
  ├─ searchQueryControllerProvider             auto-dispose   Notifier<SearchState> (query, scope, message)
  ├─ recentSearchesProvider                    auto-dispose   Stream<List<String>>
  └─ currentSearchResultsProvider              auto-dispose   Notifier<SearchResultsView>  ← synchronous
       ├─ watch searchQueryControllerProvider.select(searchedQuery)
       └─ watch searchResultsProvider(query)   auto-dispose family   Future<SearchResults>
            ├─ searchPeopleProvider(query)     family   Stream<List<User>>   (drift, by id)
            └─ searchPostsProvider(query)      family   Stream<List<Post>>   (drift, by id)
                 └─ searchHitsProvider(query)  family   Future<SearchHits>   ref.debounce(300 ms) → server

MainShell
  ├─ listen notificationsControllerProvider    auto-dispose (kept alive by this listener)
  │     └─ listen cachedNotificationsProvider  Stream<List<AppNotification>>
  └─ watch unreadNotificationCountProvider     Stream<int> (COUNT)  → UnreadBadge
NotificationsPage → watch/select notificationsControllerProvider
```

**Typing "ada":**

```
"a"   → query a   → CurrentSearchResults rebuilds (sync) → watches searchResults("a") → … → searchHits("a") waits
"ad"  → query ad  → rebuilds, watches "ad" → "a" chain disposed → its timer cancelled
"ada" → query ada → rebuilds, watches "ada" → "ad" disposed
300 ms quiet → searchHits("ada") → SearchUseCase → server → drift (cache) → hits
  → searchPeople/Posts("ada") read drift by id → searchResults("ada") → found → the page
```

**Opening a notification:**

```
tap n1 → controller.markRead(n1) → repository: drift isRead = true at once
  → cachedNotifications emits → the row loses its tint; unread COUNT emits → the badge says 2
  → server confirms (or the repository rolls back, and a SnackBar says so)
  → PostDetailRoute(p16).push
```

### Search with Bloc and with Riverpod

| | ConnectHub-Flutter (`SearchBloc`) | ConnectHub Riverpod |
|---|---|---|
| Debounce | `debounce` + `restartable()` event transformers | `ref.debounce` + a family; disposal cancels |
| Newest wins | `restartable()` cancels the running handler | only the current query's provider is watched |
| Live results | `combineLatest` of two streams | two stream providers combined by `ref.watch` |
| No flicker | the Bloc keeps `results` in state while `status: loading` | a synchronous notifier keeps the last results in a field |
| Retry | a `SearchRetried` event | `ref.invalidate(searchHitsProvider(query))` |

---

## Data Flow

```
SearchPage ─▶ SearchQueryController (query) ─▶ CurrentSearchResults ─▶ searchResults(query)
                                                                      ├─ searchPeople(query) ─┐
                                                                      └─ searchPosts(query)  ─┤─ drift (by id, live)
                                                                           searchHits(query) ─┘─ debounce → API → drift
NotificationsPage ─▶ NotificationsController ─▶ use cases ─▶ NotificationRepository ─▶ drift ◀─ API
MainShell ─▶ unreadNotificationCount (drift COUNT) ─▶ UnreadBadge
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `lib/core/common/debounce.dart` | `ref.debounce`: debounce through disposal |
| `lib/core/network/api/search_api_service.dart`, `notification_api_service.dart` (+ fakes) | The endpoints |
| `lib/core/database/tables/recent_searches_table.dart`, `notifications_table.dart`, `daos/search_dao.dart`, `daos/notifications_dao.dart` | drift v3 |
| `drift_schemas/app_database/drift_schema_v3.json`, `test/drift/app_database/generated/schema_v3.dart` | The migration |
| `lib/data/repository/search_repository_impl.dart`, `notification_repository_impl.dart` | The repositories |
| `lib/features/search/` | `search_controller.dart` (the providers and the controller), `search_state.dart` (+ `SearchResultsView`), `search_page.dart`, `widgets/` |
| `lib/features/notifications/` | `notifications_controller.dart`, `notifications_state.dart`, `notifications_page.dart` |
| `lib/features/profile/user_profile_page.dart` | The `/users/:userId` placeholder |
| `lib/core/design_system/widgets/app_search_field.dart`, `notification_tile.dart`, `unread_badge.dart` | Shared widgets |
| `test/features/search/search_controller_test.dart` | Debounce, cancellation and live results in fake time |
| `test/core/common/debounce_test.dart` | The helper alone |

---

## Important Types Added

| Type | Responsibility | Layer |
|---|---|---|
| `DebounceRef.debounce` | A disposable wait | `core/common` |
| `searchHitsProvider` … `searchResultsProvider` (families) | One query: debounced hits, live people and posts, combined | `features/search` |
| `CurrentSearchResults`, `SearchResultsView` | The results area for the current query, without flicker | `features/search` |
| `SearchQueryController`, `SearchState` | The query, the scope, recent searches | `features/search` |
| `NotificationsController`, `NotificationsState`, `NotificationFilter` | The tab | `features/notifications` |
| `unreadNotificationCountProvider` | The badge | `features/notifications` |
| `SearchRepository`, `NotificationRepository` (+ impls) | Data | domain / data |
| `SearchHits`, `SearchResults`, `SearchScope`, `AppNotification` | Models | `domain/model` |

---

## Folder Structure Changes

```
assets/json/                + notifications.json
lib/core/common/            + debounce.dart
lib/core/network/           + api/search_*, api/notification_*, dto/search_response_dto, dto/notification_dto
lib/core/database/          + tables/recent_searches_table, tables/notifications_table, daos/search_dao, daos/notifications_dao
lib/data/                   + mapper/notification_mappers, repository/search_*, repository/notification_*
lib/domain/                 + model/search_*, model/app_notification, repository/search_*, repository/notification_*, 11 use cases
lib/features/search/        search_controller, search_state, search_page, widgets/ (recent_searches, search_result_list)
lib/features/notifications/ notifications_controller, notifications_state, notifications_page
lib/features/profile/       + user_profile_page (placeholder)
drift_schemas/app_database/ + drift_schema_v3.json
```

---

## Android / iOS Comparison

| Concept | Android (MVI) | iOS (TCA) | Flutter (Bloc) | **Flutter (Riverpod)** |
|---|---|---|---|---|
| Debounce | `Flow.debounce(300)` + `flatMapLatest` | `.debounce(id:for:)` + `.cancellable(cancelInFlight:)` | `debounce` + `restartable()` | **`ref.debounce` in a family; disposal cancels** |
| Live results | `combine` of two flows | — | `combineLatest` | **two stream providers + `ref.watch`** |
| Recent searches | DataStore | — | drift | **drift** |
| Badge | a `StateFlow<Int>` from a Room count | — | a `BadgesCubit` | **a stream provider of a drift `COUNT`** |
| Kept alive from launch | the ViewModel of the main screen | the root reducer | `BlocProvider` on the shell | **`ref.listen` in the shell** |

---

## Interview Notes

- **"How do you debounce a search with Riverpod?"**
  - Make the search a family keyed by the query, and wait inside it with a timer cancelled in `ref.onDispose`.
  - When the user types on, the screen watches another key, the old provider is disposed, and its wait never ends.
- **"Why did your first version search every keystroke?"**
  - Riverpod 3 keeps a rebuilding provider's old dependencies (paused) until its new build completes.
  - An async provider watching the query took the whole debounce to complete, so every older query stayed alive.
  - A synchronous provider in between lets go at once.
- **"How do you keep the old results on screen while loading?"**
  - In the notifier that watches the query: remember the last results and return them with a "searching" flag.
  - Riverpod's own `copyWithPrevious` does this for providers that rebuild, but it's internal.
- **"How do you combine two streams?"** Two stream providers, and a third that awaits both `.future`s with `ref.watch`. When either emits, it rebuilds.
- **"How does the badge know before the tab is opened?"**
  - The shell listens to the notifications controller from launch (a no-op `ref.listen`), which creates it and keeps it alive.
  - The badge itself watches a `COUNT` query.

---

## Learning Checklist

- ✅ Debounce through disposal, proven in fake time (one search for three keystrokes; no timer left)
- ✅ The Riverpod 3 rule about previous dependencies, and a synchronous provider to work with it
- ✅ Live results from two stream providers, combined with `ref.watch`
- ✅ A badge from a drift `COUNT`; a controller kept alive by a listener
- ✅ `select` for an app bar button; optimistic read state with exact rollback
- ✅ drift v3 with a data-tested migration
- □ Families for profiles, `SharedPreferencesWithCache` and dynamic color (Phase 5)

---

## Future Improvements

- Search results page by page (the server returns everything).
- Profiles open from search and notifications today, to a placeholder; Phase 5 builds them.
- The badge setting ("Show unread badge") arrives with Settings in Phase 5.
- Live notifications (a push or a socket) would add rows to the same drift table; nothing above it would change.

---

## Notes on This Phase

- **The search field:** the spec names Material's `SearchBar`. The app uses ConnectHub-Flutter's `AppSearchField` instead: Material's `SearchBar` wraps its field in a tappable surface with no label of its own, so a screen reader stops on an unnamed control first. Same look, one labelled control.
- **Simulator check (iPhone 17 Pro):**
  - the badge read 3 at launch;
  - Search found Ada under People and her posts under Posts;
  - Notifications in dark mode: three unread, tinted, with dots;
  - tapping n1 opened p16, and coming back it was read and the badge said 2;
  - the appearance, text size and status bar were restored afterwards.
- **Builds:** the Android debug APK and the iOS simulator app.
- **Mutation checks:** 39 rules broken on purpose, one at a time. **All 39 caught** on the first pass (one assertion, the hidden zero badge, was added while writing the list):

| Area | Mutations | Notes |
|---|---:|---|
| Fake server | 7 | The viewer left out; the most followed first; posts by author; case; only your own notifications; rebased; newest first |
| drift | 6 | One recent search per query; at most 10; no blank one; the unread `COUNT`; a refresh mirroring the server; the v3 step |
| Repositories | 5 | Results in the server's order; results cached; read rolled back; a read one not sent; all-read rolled back |
| Search providers | 11 | The debounce (missing, too short, its timer cancelled); blank idle; the previous results kept; recent searches on the search key and on opening a result; a like's direction; the scope; "Try again"; a recent search in the field |
| Notifications | 10 | The badge loaded at launch, counted, hidden at zero; the Unread filter; a read one not marked again; "Mark all read" disabled; opening the post; "Nothing unread."; a failed refresh reported; the refresh behind the cache |

- **The bug the tests found before any mutation:** the first `currentSearchResults` was an async provider, and typing "a", "ad", "ada" searched all three (see *Riverpod Concepts*). It's the most useful Riverpod 3 lesson of the phase.
