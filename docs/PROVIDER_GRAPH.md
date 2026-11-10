# The provider graph

Every provider in the app: what it builds, what it depends on, and how long it lives. There are 88 of them (33 keepAlive, 55 auto-dispose), all generated from `@riverpod` / `@Riverpod(keepAlive: true)`, and every `keepAlive` says why.

- **watch:** rebuilds when the dependency changes.
- **listen:** reacts to changes without rebuilding.
- **read:** used once, in a method.

`test/di/provider_graph_test.dart` checks that the real graph builds, that an override reaches everything above it (in one container only), and which providers are kept alive.

---

## The picture

```
ProviderScope (main.dart: retry off; preferencesStoreProvider overridden)
│
├─ Platform & infrastructure (keepAlive)
│    clock · signedInUserId · assetBundle · idGenerator · networkSimulator
│    appRouter · platformColorSchemes · appVersion
│
├─ Fake backend (keepAlive)          core/network/network_providers.dart (the only way into core/network)
│    fakeServer ◀─ assetBundle, clock, idGenerator
│    fakeApiClient ◀─ fakeServer, networkSimulator
│    feedApiService · commentApiService · searchApiService · notificationApiService · userApiService ◀─ fakeApiClient, fakeServer
│    developerToolsService ◀─ networkSimulator
│
├─ Storage (keepAlive)
│    databaseConnection → appDatabase (closed on dispose)
│    preferencesStore  (throws unless overridden in main)
│
├─ Repositories (keepAlive)          di/data_providers.dart
│    feed · post · comment · search · notification · profile · savedPosts · cache · settings · demoTools
│    cacheEpoch (Notifier<int>)
│
├─ Use cases (auto-dispose, except the two settings ones)   di/use_case_providers.dart
│
└─ Features (auto-dispose, except settingsController)
     feedPosts → feedController ◀── FeedPage
     cachedPost(id), postComments(id) → postDetailController(id) ◀── PostDetailPage
     createPostController ◀── CreatePostPage
     searchHits(q) → searchPeople(q), searchPosts(q) → searchResults(q) → currentSearchResults ◀── SearchPage
     searchQueryController · recentSearches ◀── SearchPage
     cachedNotifications → notificationsController ◀── NotificationsPage, MainShell (listen)
     unreadNotificationCount ◀── MainShell (badge)
     cachedUser(id), userPosts(id) → profileController(id) ◀── ProfilePage, UserProfilePage
     savedPosts → savedPostsController ◀── ProfilePage (Saved)
     settingsController ◀── ConnectHubApp (select), MainShell (select), SettingsPage
     settingsTools ◀── SettingsPage
```

---

## Infrastructure

| Provider | Builds | Depends on | Lifetime | Why that lifetime |
|---|---|---|---|---|
| `clockProvider` | `Clock` | — | keepAlive | one clock; tests fix it |
| `signedInUserIdProvider` | `'u_demo'` | — | keepAlive | who "mine" is, for the app's life |
| `assetBundleProvider` | `rootBundle` | — | keepAlive | the seed's JSON |
| `idGeneratorProvider` | `IdGenerator` | — | keepAlive | ids for new posts and comments; seeded in tests |
| `networkSimulatorProvider` | `NetworkSimulator` | — | keepAlive | the latency and the "Simulate network failure" switch, app-wide |
| `appRouterProvider` | `GoRouter` | — | keepAlive | one router; `onDispose(router.dispose)` |
| `platformColorSchemesProvider` | wallpaper schemes or `null` | dynamic_color | keepAlive | asked once |
| `appVersionProvider` | "1.0.0 (1)" | package_info_plus | keepAlive | asked once |

## Fake backend

| Provider | Builds | Depends on (watch) | Lifetime |
|---|---|---|---|
| `fakeServerProvider` | `FakeServer` (the backend's data) | assetBundle, clock, idGenerator | keepAlive: the "server" outlives every screen |
| `fakeApiClientProvider` | `FakeApiClient` (every request crosses the simulator) | fakeServer, networkSimulator | keepAlive |
| `feedApiServiceProvider`, `commentApiServiceProvider`, `searchApiServiceProvider`, `notificationApiServiceProvider`, `userApiServiceProvider` | the fake services | fakeApiClient, fakeServer | keepAlive |
| `developerToolsServiceProvider` | `FakeDeveloperToolsService` | networkSimulator | keepAlive |

## Storage and repositories

| Provider | Builds | Depends on (watch) | Lifetime |
|---|---|---|---|
| `databaseConnectionProvider` | drift's `QueryExecutor` (a file; in memory in tests) | — | keepAlive |
| `appDatabaseProvider` | `AppDatabase` | databaseConnection | keepAlive; `onDispose(database.close)` |
| `preferencesStoreProvider` | `PreferencesStore` | — (overridden in `main`) | keepAlive |
| `feedRepositoryProvider` | cursor paging over `feed_items` | feedApiService, appDatabase | keepAlive |
| `postRepositoryProvider` | a post, a new post, optimistic like and save | feedApiService, appDatabase, clock | keepAlive |
| `commentRepositoryProvider` | comments, optimistic delete and like | commentApiService, appDatabase, postRepository, signedInUserId | keepAlive |
| `searchRepositoryProvider` | search, results by id, recent searches | searchApiService, appDatabase, clock | keepAlive |
| `notificationRepositoryProvider` | the server's read state | notificationApiService, appDatabase | keepAlive |
| `profileRepositoryProvider` | a user and their posts | userApiService, appDatabase | keepAlive |
| `savedPostsRepositoryProvider` | my bookmarks | feedApiService, appDatabase | keepAlive |
| `cacheRepositoryProvider` | Clear cache | appDatabase, signedInUserId | keepAlive |
| `settingsRepositoryProvider` | the preferences | preferencesStore | keepAlive |
| `demoToolsRepositoryProvider` | the network-failure switch | developerToolsService | keepAlive |
| `cacheEpochProvider` | `Notifier<int>`: bumped by Clear cache | — | keepAlive: app-wide; the screens come and go |

**Why repositories are keepAlive:** they hold no screen state, but they hold locks (refresh and load-more take turns) and drift streams that several screens share. One instance for the app is what ConnectHub-Flutter's `@lazySingleton` did.

## Use cases

35 providers in `di/use_case_providers.dart`, each a one-line wrapper (`LikePostUseCase(ref.watch(postRepositoryProvider))`).

- **Auto-dispose:** a use case is created when a notifier reads it, and goes when nothing does. They're cheap; the repositories underneath are kept.
- **Except `getSettingsUseCaseProvider` and `updateSettingsUseCaseProvider`:** keepAlive, because the keepAlive `SettingsController` reads them (riverpod_lint, §11.112).

## Features

| Provider | Kind | Watches | Listens | Lifetime | Read by |
|---|---|---|---|---|---|
| `feedPostsProvider` | `Stream<List<Post>>` | watchFeedUseCase | — | auto | FeedController |
| `feedControllerProvider` | `AsyncNotifier<FeedState>` | cacheEpoch | feedPosts | auto | FeedPage |
| `cachedPostProvider(id)` | `Stream<Post?>` | watchPostUseCase | — | auto family | PostDetailController |
| `postCommentsProvider(id)` | `Stream<List<Comment>>` | watchCommentsUseCase | — | auto family | PostDetailController |
| `postDetailControllerProvider(id)` | `AsyncNotifier<PostDetailState>` | cacheEpoch | cachedPost(id), postComments(id) | auto family | PostDetailPage |
| `createPostControllerProvider` | `Notifier<CreatePostState>` | — | — | auto | CreatePostPage |
| `searchHitsProvider(q)` | `Future<SearchHits>` (debounced) | cacheEpoch | — | auto family | searchPeople, searchPosts |
| `searchPeopleProvider(q)`, `searchPostsProvider(q)` | `Stream<List<…>>` | searchHits(q), the use cases | — | auto family | searchResults |
| `searchResultsProvider(q)` | `Future<SearchResults>` | searchPeople(q), searchPosts(q) | — | auto family | CurrentSearchResults |
| `currentSearchResultsProvider` | `Notifier<SearchResultsView>` (sync) | searchQueryController.select(searchedQuery), searchResults(q) | — | auto | SearchPage |
| `searchQueryControllerProvider` | `Notifier<SearchState>` | — | — | auto | SearchPage |
| `recentSearchesProvider` | `Stream<List<String>>` | watchRecentSearchesUseCase | — | auto | SearchPage |
| `cachedNotificationsProvider` | `Stream<List<AppNotification>>` | watchNotificationsUseCase | — | auto | NotificationsController |
| `unreadNotificationCountProvider` | `Stream<int>` (a `COUNT`) | watchUnreadNotificationCountUseCase | — | auto | MainShell |
| `notificationsControllerProvider` | `AsyncNotifier<NotificationsState>` | cacheEpoch | cachedNotifications | auto, **kept by the shell's `ref.listen`** | NotificationsPage |
| `cachedUserProvider(id)`, `userPostsProvider(id)` | streams | the use cases | — | auto family | ProfileController |
| `profileControllerProvider(id)` | `AsyncNotifier<ProfileState>` | cacheEpoch | cachedUser(id), userPosts(id) | auto family | ProfilePage, UserProfilePage |
| `savedPostsProvider` | `Stream<List<Post>>` | watchSavedPostsUseCase | — | auto | SavedPostsController |
| `savedPostsControllerProvider` | `AsyncNotifier<SavedPostsState>` | — | savedPosts | auto | ProfilePage (Saved) |
| `settingsControllerProvider` | `Notifier<AppSettings>` (sync) | — | — | **keepAlive**: the app root watches it for its whole life | ConnectHubApp, MainShell, SettingsPage |
| `settingsToolsProvider` | `Notifier<SettingsToolsState>` | — | — | auto | SettingsPage |

**The widgets' side:**
- **`ConnectHubApp`** watches `appRouter`, `settingsController.select(themeMode)`, `settingsController.select(useDynamicColor)` and, when that's on, `platformColorSchemes`.
- **`MainShell`** `listen`s `notificationsController` (to keep it alive), and watches `unreadNotificationCount` and `settingsController.select(showUnreadBadge)`.

---

## Three flows through the graph

**A like on the feed:**

```
PostCard ♥ → feedController.toggleLike(post) → read likePostUseCase → postRepository
  → drift: is_liked, like_count (at once) → feedPosts emits → feedController patches posts → FeedPage
                                           → cachedPost(p1) emits (if Post Detail is open) → its controller patches
  → server confirms (or the repository rolls back, and the feed's message says so)
```

**Typing "ada" in Search:**

```
searchQueryController.queryChanged('ada') → currentSearchResults rebuilds (sync)
  → watches searchResults('ada') → searchPeople/Posts('ada') → searchHits('ada') waits 300 ms
  typing on → currentSearchResults watches another query → the 'ada' chain is disposed → its timer cancelled
```

**Clear cache:**

```
settingsTools.clearCache() → clearCacheUseCase → cacheRepository → CacheDao.clearServerData(me)
  → cacheEpoch 0 → 1 → feedController, postDetailController(*), notificationsController,
    searchHits(*), profileController(*) rebuild → load again (the old content stays while loading)
```
