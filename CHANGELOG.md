# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project follows [Conventional Commits](https://www.conventionalcommits.org/).

## [0.6.0] — 2026-11-10 — Phase 6: Documentation + Architecture Comparison

### Added
- **`docs/BLOC_VS_RIVERPOD.md`:** the Feed, Search and Settings side by side with ConnectHub-Flutter's code; DI, scoping, events vs methods, testing, trade-offs, and the native editions.
- **Guides:** RIVERPOD_GUIDE, PROVIDER_GRAPH (all 88 providers and their lifetimes), SIDE_EFFECTS, API_SIMULATION, ARCHITECTURE, TESTING, LEARNING_NOTES, INTERVIEW_NOTES, ROADMAP, SCREENSHOTS (with screenshots from the simulator and the emulator).
- **Open-source files:** CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, this CHANGELOG, and the GitHub issue and PR templates.
- 6 tests (498 in total): the main Android manifest asks for the network; a pull to refresh answered after the Feed is gone; notifications, a post, a profile and a search each reloading through a real Clear cache (found by the final mutation pass, 22 rules against the whole suite).

### Fixed
- **A release build on Android would have shown no avatars or post photos:** the main manifest never asked for the network (the debug and profile manifests add it for development only).
- The demo user's bio no longer mentions a "fake auth service" (this edition has none).
- The launcher name is "ConnectHub" on both platforms (it was the package name on Android, "Connect Hub Riverpod" on iOS).

## [0.5.0] — 2026-11-10 — Phase 5: Profile + Settings

### Added
- **Profiles:** `profileControllerProvider(userId)`, a family: cached then refreshed, "This profile isn't available." for an unknown user. My profile has Posts | Saved and the Settings gear.
- **Saved posts:** offline first; unsaving offers Undo.
- **`openProfile`** from every author. My own id switches to the Profile tab, and `/users/<me>` redirects there.
- **Settings:**
  - a keepAlive, synchronous `SettingsController` over `SharedPreferencesWithCache`, opened before `runApp` and injected with `overrideWithValue`: no theme flash;
  - Appearance, "Use wallpaper colors" (dynamic_color, Android 12+), "Show unread badge";
  - Clear cache (with a confirmation), "Simulate network failure", About (package_info_plus).
- **Clear cache through an epoch:** `CacheDao.clearServerData` keeps saved posts, me and recent searches; the feed, Post Detail, notifications, search and profiles watch `cacheEpochProvider` and reload.
- 59 tests (492 in total).

### Changed
- Every controller ignores drift's emissions while it reloads, so Clear cache never flashes an empty screen.

## [0.4.0] — 2026-11-10 — Phase 4: Search + Notifications

### Added
- **drift v3:** `recent_searches` and `notifications`, with a generated migration and a v2 → v3 data test.
- **Search:**
  - `ref.debounce(300 ms)` in a family keyed by the query: disposal cancels it;
  - live people and posts, combined with `ref.watch`;
  - a synchronous `CurrentSearchResults` that keeps the previous results on screen;
  - All / People / Posts; recent searches saved on intent; Clear history.
- **Notifications:** All / Unread, mark read, mark all read (optimistic, with rollback), and a tab badge from a drift `COUNT`, live from launch.
- 96 tests (433 in total).

### Fixed
- Typing "a", "ad", "ada" searched all three: an async provider kept every older query alive (Riverpod 3 keeps previous dependencies until a rebuild completes). The provider is now synchronous.

## [0.3.0] — 2026-11-10 — Phase 3: Post Details + Comments

### Added
- **drift v2:** `comments` with likes, a generated migration and a v1 → v2 data test.
- **The fake server's posts and comments:** get and create posts; list, add, like and delete comments (only your own).
- **Post Detail:** `postDetailControllerProvider(postId)`, a family: cached then refreshed, "not found" as an `AsyncError`, comments inline with likes and delete.
- **Create Post:** a synchronous `Notifier` form, a 280-character counter, an optional image, and a discard dialog.
- 141 tests (337 in total).

## [0.2.0] — 2026-11-10 — Phase 2: Feed

### Added
- **Domain and data:** models, `Result`, `AppException`, the fake server (seeded from JSON, rebased dates), `NetworkSimulator`, API services, drift v1, repositories; all as providers.
- **`FeedController`** (an `AsyncNotifier`): the cache at once, a refresh behind it, infinite scroll, optimistic likes and saves, one-off messages.
- The Feed page in every state.
- 135 tests (196 in total).

## [0.1.0] — 2026-11-10 — Phase 1: Riverpod Foundation

### Added
- **Project setup:** Flutter 3.47.6 pinned with FVM, for Android + iOS; `material_ui`; strict analysis; CI (codegen check, format, `dart analyze --fatal-infos`, tests).
- **Riverpod:** `ProviderScope(retry: noAutomaticRetry)`, `riverpod_generator`, riverpod_lint as an analyzer plugin, the router as a keepAlive provider.
- **Design system** ported from ConnectHub-Flutter; typed routes with a four-tab shell; the accessibility tour; architecture tests.
- 61 tests, the first README, the MIT LICENSE and the Phase 1 summary.
