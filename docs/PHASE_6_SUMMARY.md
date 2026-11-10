# Phase 6 — Documentation + Architecture Comparison

## Phase Goal

Turn the app into what it was built to be: a fair, readable comparison of Bloc and Riverpod on one codebase, and a learning resource for Riverpod 3.
- **The interview payload:** `BLOC_VS_RIVERPOD.md`, with the real code from both repos, not toy examples.
- **The guides:** how Riverpod is used here (`RIVERPOD_GUIDE.md`), every provider and its lifetime (`PROVIDER_GRAPH.md`), the effects (`SIDE_EFFECTS.md`), and the open-source set.
- **The close-out:**
  - a release build on a device, which found a release-only bug;
  - screenshots in light, dark, large text and wallpaper colors;
  - a final mutation pass against the whole suite.

No new features: the code changes are one fix, two names, three comments and one seed string.

---

## What Was Implemented

- **Docs (`docs/`):**
  - `BLOC_VS_RIVERPOD.md`:
    - data-flow diagrams;
    - the Feed, Search and Settings side by side (state holders, pages, the debounce, the store before `runApp`);
    - DI, scoping, events vs methods, testing;
    - trade-offs with measured sizes, when to pick which, and the MVI / TCA mapping;
  - `RIVERPOD_GUIDE.md`: providers, `ref`, notifiers, `AsyncValue`, families, lifetimes, the patterns built from them, testing, riverpod_lint;
  - `PROVIDER_GRAPH.md`: all 88 providers, what each watches and listens to, its lifetime and why, and three flows through the graph;
  - `SIDE_EFFECTS.md`: effects consumed once, `ref.mounted`, optimistic writes, refresh behind the cache, the reload guard, the epoch, retry;
  - `API_SIMULATION.md`, `ARCHITECTURE.md`, `TESTING.md`, `LEARNING_NOTES.md`, `INTERVIEW_NOTES.md`, `ROADMAP.md`, `SCREENSHOTS.md` (13 screenshots in `docs/screenshots/`).
- **Open-source files:** `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md` (0.1.0–0.6.0), `.github/ISSUE_TEMPLATE/` (bug, feature), `.github/PULL_REQUEST_TEMPLATE.md`.
- **The final README:** status, features, docs (with "start here"), screenshots, roadmap, contributing.
- **Fixed:**
  - **The main Android manifest had no INTERNET permission.** Debug and profile manifests add it, so every debug run loaded images; a release build would have shown only fallbacks. Added, with `test/platform/android_manifest_test.dart`.
  - **The launcher names:** "ConnectHub" on both platforms (Android showed `connect_hub_riverpod`, iOS "Connect Hub Riverpod").
  - **The demo user's bio** said "the fake auth service", which this edition doesn't have: now "the fake server".
  - **Three stale comments:** the router "reads other providers" (it doesn't: routes reach the container with `ProviderScope.containerOf`), and two "Phase N" notes about the future.
- **498 tests** (5 new from the final mutation pass, plus the manifest test).

---

## Riverpod Concepts Demonstrated

No new code, so this phase's Riverpod content is in what the docs had to explain:
- **Counting the graph:**
  - 88 providers: 33 keepAlive, 55 auto-dispose;
  - 33 of the auto-dispose ones are use cases, and 10 providers are families keyed by a post id, a user id or a query.
  - Writing `PROVIDER_GRAPH.md` meant checking each provider's real dependencies, and a first draft had several wrong (the fake client doesn't read the signed-in user; the feed repository doesn't read the clock). The table now comes from the source.
- **What Riverpod trades away:**
  - The DI wiring is 384 hand-written lines, against injectable's 121 annotations and a generated file.
  - The screens' state holders are smaller: Feed 178 → 144 lines, Search 312 → 168, Settings 115 → 74 (non-blank, non-comment).
  - `BLOC_VS_RIVERPOD.md` reports both.
- **The rules that only Riverpod has:**
  - previous dependencies kept until a rebuild completes;
  - `ref` unusable after disposal;
  - `isLoading` surviving `invalidate`;
  - keepAlive-only-uses-keepAlive.
  These are the "learning curve" row of the trade-offs, each with the bug it caused here.

---

## Flutter / Dart Concepts Demonstrated

- **Release-only behaviour:**
  - `android/app/src/debug/AndroidManifest.xml` and `profile/` add INTERNET for development, so a missing main-manifest permission can't be seen in debug.
  - A test that reads the manifest file is the cheapest guard (conventions §11.98; ConnectHub-Flutter and MovieExplorer had the same gap).
- **`android:label` and `CFBundleDisplayName`** are the launcher names; `flutter create` fills them from the package name.
- **Screenshots from the command line:** `simctl status_bar override`, `simctl ui appearance` / `content_size`, `simctl io screenshot`; `adb exec-out screencap`. Typed text follows the simulator keyboard's layout (§11.69), so the composer's text was pasted (`simctl pbcopy`) instead.

---

## Provider Graph & State Flow

Unchanged from Phase 5; the whole graph is now in [PROVIDER_GRAPH.md](PROVIDER_GRAPH.md):

```
ProviderScope (main.dart: retry off; preferencesStoreProvider overridden)
├─ Platform & infrastructure (keepAlive)   clock · signedInUserId · router · simulator · wallpaper colors · version
├─ Fake backend (keepAlive)                fakeServer → fakeApiClient → 6 API services
├─ Storage (keepAlive)                     databaseConnection → appDatabase · preferencesStore
├─ Repositories (keepAlive)                10 repositories · cacheEpoch
├─ Use cases (auto-dispose; 2 keepAlive)   35
└─ Features (auto-dispose; settings keepAlive)
     feed · postDetail(id) · createPost · search(q)… · notifications · profile(id) · savedPosts · settings · settingsTools
```

**The release check, through the graph:**

```
Settings → "Use wallpaper colors" on → settingsController.setUseDynamicColor(true)
  → ConnectHubApp's select(useDynamicColor) changes → watches platformColorSchemesProvider (the wallpaper's palette)
  → MaterialApp(theme: AppTheme.fromScheme(wallpaper.light)) → the app turns blue at once
  → SharedPreferencesWithCache stores it → after a force-stop and relaunch, SettingsController.build() reads it → blue on the first frame
```

---

## Data Flow

Unchanged. The diagrams now live in [ARCHITECTURE.md](ARCHITECTURE.md) and, side by side with ConnectHub-Flutter's, in [BLOC_VS_RIVERPOD.md](BLOC_VS_RIVERPOD.md#1-data-flow).

---

## Important Files Added

| File | Purpose |
|---|---|
| `docs/BLOC_VS_RIVERPOD.md` | The comparison with ConnectHub-Flutter, with real code |
| `docs/RIVERPOD_GUIDE.md` | Riverpod as used here |
| `docs/PROVIDER_GRAPH.md` | Every provider and its lifetime |
| `docs/SIDE_EFFECTS.md` | Effects, `ref.mounted`, optimistic writes, retry |
| `docs/API_SIMULATION.md`, `ARCHITECTURE.md`, `TESTING.md` | Reference |
| `docs/LEARNING_NOTES.md`, `INTERVIEW_NOTES.md`, `ROADMAP.md`, `SCREENSHOTS.md`, `screenshots/` | Learning and showcase |
| `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md`, `.github/` templates | The open-source set |
| `test/platform/android_manifest_test.dart` | The release build asks for the network |

---

## Important Types Added

None: this phase adds docs, one test and one manifest line.

---

## Folder Structure Changes

```
CONTRIBUTING.md  CODE_OF_CONDUCT.md  SECURITY.md  CHANGELOG.md          (new)
.github/          + ISSUE_TEMPLATE/bug_report.md, feature_request.md, PULL_REQUEST_TEMPLATE.md
docs/             + BLOC_VS_RIVERPOD, RIVERPOD_GUIDE, PROVIDER_GRAPH, SIDE_EFFECTS, API_SIMULATION,
                    ARCHITECTURE, TESTING, LEARNING_NOTES, INTERVIEW_NOTES, ROADMAP, SCREENSHOTS,
                    PHASE_6_SUMMARY, screenshots/ (13)
test/platform/    + android_manifest_test.dart
```

---

## Android / iOS Comparison

| Concept | Android (MVI) | iOS (TCA) | Flutter (Bloc) | **Flutter (Riverpod)** |
|---|---|---|---|---|
| The comparison doc | `MVVM_VS_MVI.md` | `MVVM_VS_TCA.md` | — (the base edition) | **`BLOC_VS_RIVERPOD.md`** |
| A graph of dependencies | Hilt's component graph | `DependencyValues` | the generated `injection.config.dart` | **`PROVIDER_GRAPH.md`, from the source** |
| Release-only checks | R8 / ProGuard rules | Release configuration | the same manifest gap, fixed with a test | **the same test** |
| Dynamic color | `dynamicLightColorScheme` | — | dynamic_color | **dynamic_color behind a provider** |

---

## Interview Notes

- **"How would you compare Bloc and Riverpod fairly?"**
  - Build the same screens on the same domain and data layers, and measure.
  - Riverpod's state holders were smaller, and its DI wiring larger.
  - Bloc's concurrency is explicit (`restartable()`); Riverpod's comes from disposal, and depends on rules you have to know (previous dependencies kept until a rebuild completes).
- **"What can only a release build tell you?"**
  - Anything the debug configuration adds for you: here the INTERNET permission, which debug and profile manifests add.
  - Check release builds on a device before shipping, and guard what you can with a test.
- **"How do you document a provider graph?"**
  - One table per layer: what each provider builds, what it watches and listens to, its lifetime and why.
  - Generate the list from the source, then check the dependencies by reading the code, not from memory.

---

## Learning Checklist

- ✅ A Bloc vs Riverpod comparison with real code, measured sizes and honest trade-offs
- ✅ Every provider documented with its lifetime
- ✅ Effects, lifetimes and retry explained where they happen
- ✅ The open-source set, CI confirmed on a clean copy
- ✅ A release build on a device (and the bug it found)
- ✅ Screenshots: light, dark, large text, wallpaper colors
- ✅ A final mutation pass against the whole suite
- ✅ **ConnectHub Riverpod is complete**

---

## Future Improvements

See [ROADMAP.md](ROADMAP.md):
- a `ProviderObserver`;
- scoped overrides;
- opt-in retry;
- Riverpod's experimental offline persistence and mutations;
- follow, edit profile, sign-in and chat (to compare with ConnectHub-Flutter's `AuthBloc` and realtime chat).

---

## Notes on This Phase

- **Release build (Android, Pixel 10 Pro emulator, API 36):**
  - `flutter build apk --release` → `adb install -r` → `pm clear` → launch;
  - the feed showed its photos and avatars (with the INTERNET fix);
  - Settings showed "Use wallpaper colors", and turning it on restyled the app in the wallpaper's blue at once;
  - after a force-stop and relaunch it was still blue (persisted, and read on the first frame).
- **Screenshots (iOS simulator, fresh install):**
  - light, dark, and AX3 (about 235 %);
  - at AX3, Appearance became a radio list and the profile's counts wrapped;
  - the simulator was restored afterwards (light, `large`, status bar cleared).
- **Docs checked against the code:**
  - every claim about a provider's dependencies, a string or a file was checked by reading or grepping the source;
  - wrong first drafts were fixed: the dependency table, "This post isn't available" (it's "no longer available"), and a lock claimed for every repository (only the post repository and the feed window have one).
- **The final mutation pass:**
  - 22 key rules from all six phases, broken one at a time, each run against the **whole suite** (not just the area's tests);
  - **17 were caught on the first pass; the other 5 now are**, by five new tests.
  - Every survivor was a real gap:
    - *No `ref.mounted` check after a pull to refresh:* only a like had been tested answering after the Feed was gone. A test now closes the Feed during a refresh.
    - *Search hits, notifications and Post Detail ignoring the cache epoch:* Phase 5 tested the epoch on the feed and the profile only. `clear_cache_reload_test.dart` now runs a real Clear cache under each screen and records every state.
    - *The profile patched while reloading:* its test bumped the epoch without clearing anything, so no emptied table ever arrived. The new test clears for real, and finds "0 posts" without the guard.
  - The runner flags a mutation that fails to compile separately, so a broken mutation can't pass for a catch; none did.

| Area | Mutations | Notes |
|---|---:|---|
| Feed | 4 | the `ref.mounted` check; the refresh behind the cache; an error with nothing shown; the message consumed |
| Search | 4 | the timer cancelled on disposal; the debounce; the previous results kept; the epoch |
| Data | 4 | a like rolled back; upserts, not `REPLACE`; only the author deletes a comment; 280 characters |
| Retry | 2 | the policy never retries; `main` turns retry off |
| Settings | 2 | kept alive; read synchronously (no theme flash) |
| Clear cache | 5 | the badge alive from launch; notifications, Post Detail and the profile reload; saved posts kept |
| Release | 1 | the manifest asks for the network |

- **Over the six phases:** 210 mutations (24 + 43 + 49 + 39 + 33 + 22). 197 were caught on the first pass, and the other 13 by tests added for them.
- **Generated doc comments:** fixing the router's doc comment changed `app_router.g.dart`, because riverpod_generator copies a provider's documentation into the generated file. A comment-only edit needs `build_runner`, or CI's codegen check fails (conventions §11.116).
