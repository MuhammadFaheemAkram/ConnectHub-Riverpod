# Phase 5 — Profile + Settings

## Phase Goal

The last two features, each teaching one Riverpod idea:
- **Profiles as a family.**
  - Any profile, mine or anyone's, is `profileControllerProvider(userId)`: one controller class, one instance per user id, disposed when its screen closes.
  - My Profile tab adds Saved (with Undo) and the Settings gear; `/users/<my id>` redirects to it.
- **Settings as app-wide state.**
  - The preferences are a `keepAlive`, **synchronous** notifier read from `SharedPreferencesWithCache`. The store is opened before `runApp` and injected with the app's one provider override, so the saved theme is there on the first frame (no light flash).
  - Clear cache bumps an app-wide **epoch** that every screen showing server data watches, so they all reload.

---

## What Was Implemented

- **Fake server:** `getUser` (or a 404), `getUserPosts` (newest first), `getBookmarks` (the viewer's saved posts, most recently saved first).
- **APIs:** `UserApiService`, `DeveloperToolsService` (the network-failure switch over `NetworkSimulator`), `FeedApiService.getBookmarks`; fakes and providers.
- **drift (still v3):**
  - `UsersDao` and `BookmarksDao`;
  - `PostsDao.watchPostsByAuthor` / `replacePostsByAuthor`;
  - `CacheDao.clearServerData(keepUserId)` (deletes the feed, comments, notifications, unsaved posts and other users; keeps saved posts, their authors, me and recent searches).
- **Storage:** `PreferencesStore` (`core/storage`), an interface over `SharedPreferencesWithCache`; tests use `MemoryPreferencesStore`.
- **Domain and data:**
  - `AppSettings` (theme mode, wallpaper colors, unread badge) and `AppThemeMode`;
  - five repositories: profile, saved posts, cache, settings, demo tools;
  - eleven use cases.
- **Platform** (`core/platform`):
  - `platformColorSchemesProvider` (dynamic_color: the wallpaper's schemes, or `null`);
  - `appVersionProvider` (package_info_plus: "1.0.0 (1)").
- **Theme:** `AppTheme.fromScheme(scheme)`; light and dark built from the seed through it. The app uses the wallpaper's schemes when "Use wallpaper colors" is on and the platform has them.
- **Profile** (`features/profile/`):
  - `cachedUserProvider(userId)`, `userPostsProvider(userId)`, `savedPostsProvider` (live from drift);
  - `ProfileController(userId)`: cached then refreshed; a 404 is "This profile isn't available."; like, save, pull to refresh;
  - `SavedPostsController`: offline first, then the server; unsave with Undo;
  - `ProfileView`:
    - the header (avatar, name, bio, Followers / Following / Posts in a `Wrap`);
    - Posts | Saved and the gear (mine only); a back button to the feed on someone else's;
  - `ProfilePage` (the tab) and `UserProfilePage` (`/users/:userId`, which replaces Phase 4's placeholder).
- **Opening profiles:** `openProfile(context, userId)` from the feed, Post Detail (the post's and comments' authors), Search and Notifications. My id switches to the tab; anyone else's profile is pushed.
- **Settings** (`features/settings/`):
  - `SettingsController` (keepAlive, synchronous; each change applies at once and is stored);
  - `SettingsTools` (auto-dispose: Clear cache, the network switch);
  - `SettingsPage`:
    - Appearance (a `SegmentedButton`; radio buttons at large text sizes);
    - "Use wallpaper colors" (only where the platform has them) and "Show unread badge";
    - Clear cache (with a confirmation);
    - "Simulate network failure";
    - About (the version, the licenses).
- **The shell:** the badge shows only while "Show unread badge" is on.
- **`CacheEpoch`:** watched by the feed, Post Detail, notifications, search hits and profiles.
- **492 tests.**

---

## Riverpod Concepts Demonstrated

- **A family for a screen's controller:**
  ```dart
  @riverpod
  class ProfileController extends _$ProfileController {
    @override
    Future<ProfileState> build(String userId) async { … }
  }
  // ref.watch(profileControllerProvider('u_ada'))
  ```
  - Ada's and Grace's profiles are two instances with separate state, each disposed when nothing watches it.
  - The user id is the key, and it's a field of the notifier (`userId`), so the methods don't take it again.
- **A provider that must be overridden:**
  ```dart
  @Riverpod(keepAlive: true)
  PreferencesStore preferencesStore(Ref ref) => throw UnimplementedError(
    'preferencesStoreProvider must be overridden before runApp (see main.dart)');

  // main.dart, after `await SharedPreferencesWithCache.create(…)`:
  ProviderScope(overrides: [
    preferencesStoreProvider.overrideWithValue(SharedPreferencesStore(preferences)),
  ], …)
  ```
  This is how an object that needs an `await` to exist (the opened store) enters a synchronous graph. ConnectHub-Flutter used injectable's `@preResolve` for this. Tests override it with `MemoryPreferencesStore`.
- **A synchronous notifier for state the first frame needs:** `SettingsController.build()` returns `AppSettings`, not a `Future`. `ConnectHubApp` watches it, so `MaterialApp` gets the saved theme mode on its first build. A test pumps the app once with "dark" stored and checks the first frame's brightness.
- **`select` at the root:** the app widget watches `settingsControllerProvider.select((s) => s.themeMode)` and `.select((s) => s.useDynamicColor)`. Turning the badge off doesn't rebuild `MaterialApp`; the shell watches that slice instead.
- **An epoch to reload many screens:**
  - `CacheEpoch` is a keepAlive `Notifier<int>`, and Clear cache calls `cleared()` (`state++`).
  - Each controller showing server data has `ref.watch(cacheEpochProvider)` in its `build`, so a bump rebuilds it, and it loads again from an empty cache.
  - In ConnectHub-Flutter each Cubit subscribed to a "cache cleared" stream and reset itself; here it's one line per screen.
- **No "nothing" while it reloads:**
  - Between the bump and the new load, the drift streams that the old build listened to emit the emptied tables.
  - Every controller's `_update` now ignores them while `state.isLoading`, so the screen keeps the old content under the loading state instead of flashing empty.
  - A mutation removing the guard is caught by a test that records the feed's states during Clear cache.
- **`keepAlive` only uses `keepAlive`:**
  - riverpod_lint's `only_use_keep_alive_inside_keep_alive` flagged the keepAlive `SettingsController` reading auto-dispose use-case providers;
  - an app-lifetime provider holding an auto-dispose one would keep it alive by accident, or watch it be disposed;
  - the two settings use cases are keepAlive too.
- **Capturing before an `await`:**
  - `SettingsTools` is auto-dispose, so if Settings closes while the cache is clearing, its `ref` is gone after the `await`;
  - it reads `cacheEpochProvider.notifier` *before* awaiting, so the app-wide bump still happens;
  - a test closes the listener mid-clear and checks the epoch.
- **Reading a provider from a route:** `UserProfileRoute.redirect` isn't a widget, so it reaches `signedInUserIdProvider` through `ProviderScope.containerOf(context, listen: false)`.

---

## Flutter / Dart Concepts Demonstrated

- **`SharedPreferencesWithCache`:**
  - the cached API (`get*` is synchronous once created) with an `allowList` of the three keys;
  - tests use `SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty()`, so the real class is tested too.
- **`WidgetsFlutterBinding.ensureInitialized()` before `runApp`:** the preferences use a platform channel.
- **dynamic_color:** `DynamicColorPlugin.getCorePalette()` answers on Android 12+ only. On iOS (and in tests) there's no answer, so the provider returns `null` and Settings hides the switch.
- **`AboutListTile`:** the licenses page, with the app's name and version.
- **`TabBar` without a `TabBarView`:** Posts | Saved switch the list below the header inside one scroll view, so the header scrolls away with either.
- **Running the real `main()` in a test:** once per file, because it opens a real database. Not inside `runAsync`, where the app's animations saw time go backwards (see *Notes*).

---

## Provider Graph & State Flow

```
ProviderScope(overrides: [preferencesStoreProvider ← SharedPreferencesStore])

ConnectHubApp
  ├─ watch settingsControllerProvider.select(themeMode)        keepAlive   Notifier<AppSettings>  ← synchronous
  ├─ watch settingsControllerProvider.select(useDynamicColor)      └─ read getSettingsUseCase → SettingsRepository → preferencesStore
  ├─ watch platformColorSchemesProvider                        keepAlive   Future<PlatformColorSchemes?>
  └─ watch appRouterProvider
MainShell
  └─ watch settingsControllerProvider.select(showUnreadBadge) → UnreadBadge (or none)

ProfilePage / UserProfilePage(userId)
  └─ profileControllerProvider(userId)                         auto-dispose family   AsyncNotifier<ProfileState>
       ├─ watch cacheEpochProvider                             keepAlive   Notifier<int>
       ├─ listen cachedUserProvider(userId)                    family      Stream<User?>        (drift)
       └─ listen userPostsProvider(userId)                     family      Stream<List<Post>>   (drift)
ProfilePage → Saved
  └─ savedPostsControllerProvider                              auto-dispose   AsyncNotifier<SavedPostsState>
       └─ listen savedPostsProvider                            Stream<List<Post>>   (drift: bookmarks)

SettingsPage
  ├─ watch settingsControllerProvider
  ├─ watch settingsToolsProvider                               auto-dispose   Notifier<SettingsToolsState>
  │     └─ clearCache → ClearCacheUseCase → CacheDao → cacheEpochProvider.cleared()
  ├─ watch platformColorSchemesProvider   (show "Use wallpaper colors"?)
  └─ watch appVersionProvider

cacheEpochProvider ◀─ watched by feedController, postDetailController(postId),
                      notificationsController, searchHits(query), profileController(userId)
```

**Choosing Dark:**

```
tap Dark → SettingsController.setThemeMode(dark)
  → state = settings.copyWith(themeMode: dark)       (at once)
  → ConnectHubApp's select(themeMode) changed → MaterialApp(themeMode: dark)
  → UpdateSettingsUseCase → SettingsRepository → SharedPreferencesWithCache ('settings.themeMode' = 'dark')
next launch: main awaits the store → SettingsController.build() reads 'dark' → first frame dark
```

**Clear cache:**

```
Settings → "Clear cache?" → Clear → SettingsTools.clearCache()
  → isClearingCache → CacheDao.clearServerData(me)   (saved posts, their authors, me and recent searches stay)
  → cacheEpoch 0 → 1
  → every controller watching it rebuilds: loading (the old content stays; _update ignores the emptied streams)
  → each loads from the server again → data
  → "Cache cleared. Posts and notifications download again."
```

### Settings with Bloc and with Riverpod

| | ConnectHub-Flutter | ConnectHub Riverpod |
|---|---|---|
| The store before the app | injectable `@preResolve` | `await` in `main` + `overrideWithValue` |
| Settings state | `SettingsCubit`, provided above `MaterialApp` | `settingsControllerProvider` (keepAlive, synchronous) |
| Rebuild only on theme | `BlocSelector` | `ref.watch(provider.select(…))` |
| Reload after Clear cache | a "cache cleared" stream each Cubit subscribed to | `ref.watch(cacheEpochProvider)` in each `build` |
| A profile per user | a `ProfileCubit` created per route with the id | a family keyed by the id |

---

## Data Flow

```
SettingsPage ─▶ SettingsController ─▶ get/updateSettings ─▶ SettingsRepository ─▶ PreferencesStore ─▶ SharedPreferencesWithCache
SettingsPage ─▶ SettingsTools ─▶ clearCache ─▶ CacheRepository ─▶ CacheDao (drift)
                               └▶ cacheEpoch++ ─▶ every server-data controller reloads
ProfileView ─▶ ProfileController(userId) ─▶ watch/refresh user & posts ─▶ ProfileRepository ─▶ drift ◀─ UserApiService
ProfileView (Saved) ─▶ SavedPostsController ─▶ SavedPostsRepository ─▶ drift (bookmarks) ◀─ FeedApiService.getBookmarks
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `lib/core/storage/preferences_store.dart` | `PreferencesStore` and `SharedPreferencesStore` |
| `lib/core/platform/platform_providers.dart` | Wallpaper colors and the app's version |
| `lib/core/network/api/user_api_service.dart`, `developer_tools_service.dart` (+ fakes) | The endpoints |
| `lib/core/database/daos/users_dao.dart`, `bookmarks_dao.dart`, `cache_dao.dart` | drift |
| `lib/data/repository/profile_*`, `saved_posts_*`, `cache_*`, `settings_*`, `demo_tools_*` | The repositories |
| `lib/features/profile/` | `profile_controller.dart`, `profile_state.dart`, `profile_view.dart`, `profile_page.dart`, `user_profile_page.dart`, `widgets/profile_header.dart` |
| `lib/features/settings/` | `settings_controller.dart`, `settings_state.dart`, `settings_page.dart` |
| `lib/app/theme_mode_mapper.dart` | `AppThemeMode` → `ThemeMode` |
| `test/features/settings/settings_page_test.dart` | No theme flash, the switches, Clear cache, About |
| `test/data/repository/settings_repository_impl_test.dart` | Persistence through the real `SharedPreferencesWithCache` |
| `test/core/database/cache_dao_test.dart` | What Clear cache deletes and keeps |

---

## Important Types Added

| Type | Responsibility | Layer |
|---|---|---|
| `ProfileController` (family), `ProfileState` | Anyone's profile | `features/profile` |
| `SavedPostsController`, `SavedPostsState` | Saved, with Undo | `features/profile` |
| `SettingsController`, `AppSettings`, `AppThemeMode` | The preferences | `features/settings` / `domain/model` |
| `SettingsTools`, `SettingsToolsState` | Clear cache, the network switch | `features/settings` |
| `CacheEpoch` | "The cache was cleared": reload | `di` |
| `PreferencesStore`, `preferencesStoreProvider` | Key-value storage, overridden in `main` | `core/storage`, `di` |
| `platformColorSchemesProvider`, `appVersionProvider` | The platform | `core/platform` |
| `ProfileRepository`, `SavedPostsRepository`, `CacheRepository`, `SettingsRepository`, `DemoToolsRepository` (+ impls) | Data | domain / data |

---

## Folder Structure Changes

```
lib/app/                    + theme_mode_mapper
lib/core/storage/           + preferences_store                  (new)
lib/core/platform/          + platform_providers                 (new)
lib/core/network/           + api/user_*, api/developer_tools_*
lib/core/database/daos/     + users_dao, bookmarks_dao, cache_dao
lib/data/repository/        + profile_*, saved_posts_*, cache_*, settings_*, demo_tools_*
lib/domain/                 + model/app_settings, model/app_theme_mode, 5 repositories, 11 use cases
lib/features/profile/       profile_controller, profile_state, profile_view, profile_page, user_profile_page, widgets/profile_header
lib/features/settings/      settings_controller, settings_state, settings_page   (no longer placeholders)
```

---

## Android / iOS Comparison

| Concept | Android (MVI) | iOS (TCA) | Flutter (Bloc) | **Flutter (Riverpod)** |
|---|---|---|---|---|
| Preferences | DataStore (a `Flow`) | `@AppStorage` / `UserDefaults` | `SharedPreferencesWithCache` via `@preResolve` | **the same store, injected with `overrideWithValue`** |
| No theme flash | `runBlocking` first read / splash | `UserDefaults` is synchronous | a Cubit seeded before `runApp` | **a synchronous keepAlive notifier** |
| Dynamic color | `dynamicLightColorScheme` (12+) | — | dynamic_color | **dynamic_color behind a provider** |
| A profile per user | a ViewModel with `SavedStateHandle` id | a reducer state with the id | a Cubit per route | **a family keyed by the id** |
| Reload after Clear cache | the repositories' flows re-emit | — | a "cleared" stream per Cubit | **an epoch every screen watches** |

---

## Interview Notes

- **"How do you get an async-initialized object into Riverpod?"** Give the provider no real default (throw a clear error), `await` the object in `main`, and `overrideWithValue` it in the root `ProviderScope`. Everything below reads it synchronously.
- **"How do you avoid a theme flash?"** The settings are read synchronously from a store opened before `runApp`, so the first frame has them. An async settings provider would build once with a default first.
- **"What is a family, and when do you use one?"** A provider with a parameter: one instance per value, cached and disposed separately. Use one for a screen about one thing (a post, a profile), or a query.
- **"How do you make every screen reload after clearing a cache?"** A counter provider that each screen's controller watches; bumping it rebuilds them all. Each one guards its stream updates while reloading, so they don't flash empty.
- **"What does `only_use_keep_alive_inside_keep_alive` protect against?"** An app-lifetime provider depending on a screen-lifetime one: the dependency would either be kept alive by accident or disposed under it.
- **"Why read the epoch's notifier before the `await` in Clear cache?"** The screen-scoped notifier may be disposed by the time the clear finishes, and using its `ref` then throws. What must happen anyway is captured first.

---

## Learning Checklist

- ✅ A family controller for profiles; my id redirected to the tab
- ✅ A provider overridden in `main` with an awaited object
- ✅ Synchronous keepAlive settings and no theme flash (tested on the first frame)
- ✅ `select` at the app root; the badge setting in the shell
- ✅ An epoch provider to reload every server-data screen, without an empty flash
- ✅ riverpod_lint's keepAlive rule; capturing a notifier before an `await`
- ✅ dynamic_color and package_info_plus behind providers
- □ Offline-first polish, accessibility and the final tour (Phase 6)

---

## Future Improvements

- Follow / unfollow (the counts are the seed's).
- Edit my profile (name, bio, avatar).
- "Use wallpaper colors" is Android 12+ only; iOS has no wallpaper palette.
- Clear cache could also clear the image cache (`CachedNetworkImage`), which keeps its own files.

---

## Notes on This Phase

- **The theme-flash test:** the first attempt ran the real `main()` inside `runAsync`, and the app's animations failed on `elapsedInSeconds >= 0` (time went backwards between real and fake clocks). The flash test now pumps `ConnectHubApp` once with a `MemoryPreferencesStore` holding "dark". One test still runs the real `main()` in fake time and checks the injected store.
- **Riverpod wraps build errors:** reading `preferencesStoreProvider` without its override throws a `ProviderException` wrapping the `UnimplementedError`, so the graph test matches the message.
- **Simulator check (iPhone 17 Pro):**
  - my Profile: avatar, name, bio, 128 / 87 / 2, Posts | Saved and the gear;
  - Settings in light, then Dark (applied at once);
  - Saved empty ("Nothing saved yet…"), then a bookmarked post in it; unsaving showed "Removed from saved" with Undo, and Undo brought it back;
  - Ada's profile from the feed: a back button, no gear, no Saved;
  - the appearance, text size and status bar were restored afterwards.
- **Builds:** the Android debug APK and the iOS simulator app.
- **Mutation checks:** 33 rules broken on purpose, one at a time. **29 caught on the first pass; the other 4 now are**, by three new tests and one stronger one:
  - *Clear cache forgets me:* the repository passed my id to the DAO untested (only the DAO was). A repository test now keeps me and forgets Ada.
  - *The feed patched while reloading* (the `!state.isLoading` guard removed): nothing recorded the feed during Clear cache. A test now does, and finds "0 posts" without the guard.
  - *My id pushed instead of switching tabs:* go_router accepted the redirected push, so the tab was right, but the post stayed underneath. The test now also checks that the router can't pop.
  - *Clear cache without asking:* only "Clear" was tapped. A test now taps Cancel and checks that nothing was cleared.

| Area | Mutations | Notes |
|---|---:|---|
| Fake server | 3 | A user's posts only; saved posts most recent first; an unknown user is a 404 |
| drift | 4 | Clear cache keeps saved posts, keeps me, deletes comments; an author's refresh drops gone posts |
| Repositories | 5 | An unknown user's cached posts go; the badge on by default; the theme stored and applied; Clear cache keeps me |
| Settings | 11 | Persisted; read at start; the epoch bumped; the network switch; the badge setting; the wallpaper switch shown and used; dark is dark; Clear cache asks; the version; `main` injects the store |
| Epoch and profiles | 10 | The feed and profiles watch the epoch; no patch while reloading; Undo offered and saving; "not available" for a 404; Saved and the gear mine only; my id to the tab, and redirected |
