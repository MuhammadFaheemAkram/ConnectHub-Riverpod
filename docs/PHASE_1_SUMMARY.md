# Phase 1 — Riverpod Foundation

## Phase Goal

Set up everything the features will stand on, the Riverpod way:
- **the project:** FVM-pinned Flutter 3.47.6, strict analysis, code generation, CI;
- **Riverpod itself:** the `ProviderScope` at the root, `riverpod_generator` for providers, `riverpod_lint` in the analyzer, and a decision about automatic retry;
- **the first provider:** the router, kept alive for the app's lifetime, and tested without widgets through `ProviderContainer.test()`;
- **the UI frame:** ConnectHub's design system (ported), typed routes, a four-tab shell (Feed · Search · Notifications · Profile) with placeholder pages, and Settings above the tabs.

This edition rebuilds a slice of [ConnectHub-Flutter](https://github.com/MuhammadFaheemAkram/ConnectHub-Flutter) to compare Bloc and Riverpod. Phase 1 already shows the first difference: there is no `getIt`, no `configureDependencies()`, no `BlocProvider`, and no `StatefulWidget` owning a router. One `ProviderScope` holds the graph.

---

## What Was Implemented

- **Project:**
  - `flutter create --org co.bitfuse.flutter`, package `connect_hub_riverpod`, Android and iOS;
  - `.fvmrc` (3.47.6);
  - `material_ui` instead of the in-SDK Material (`dart fix --code=migrate_design_widgets`);
  - `analysis_options.yaml`: ConnectHub's strict modes and lints, plus the `riverpod_lint` plugin;
  - `build.yaml`: lint-free generated parts;
  - an MIT LICENSE.
- **Packages:**
  - `flutter_riverpod` 3.5.0, `riverpod_annotation` 4.0.8, `go_router` 18.1.4;
  - dev: `riverpod_generator` 4.0.10, `go_router_builder` 4.5.3, `build_runner` 2.17.1;
  - `riverpod_lint` 3.2.0 through `analysis_options.yaml` (an analyzer plugin, not a dependency).
- **Riverpod:**
  - `main.dart` runs `ConnectHubApp` inside `ProviderScope(retry: noAutomaticRetry)`;
  - `noAutomaticRetry` (`app/retry_policy.dart`) turns Riverpod 3's automatic retry off app-wide, with the reason;
  - `appRouterProvider` (`@Riverpod(keepAlive: true)`) builds the `GoRouter` and disposes it with its container.
- **App:** `ConnectHubApp` is a `ConsumerWidget` that watches the router provider; light and dark themes follow the device.
- **Design system (ported from ConnectHub-Flutter):**
  - `AppTheme` (Material 3, seed `#0F766E`, `fidelity`);
  - `AppColors` (`like`, `unread`);
  - `AppSpacing`, `AppRadius`, `AppIconSize`;
  - the large-text rule (`prefersStackedLayout`);
  - `LoadingView`, `ErrorView`, `EmptyStateView`.

  The rest (post card, comment and notification tiles, avatar) comes with the features that use it.
- **Navigation:**
  - typed routes: a `StatefulShellRoute` with four branches (`/feed`, `/search`, `/notifications`, `/profile`);
  - root-level `/settings`;
  - "Page not found" with a way back to the feed.
- **Screens:**
  - `MainShell` (a `NavigationBar`; re-tapping a tab returns it to its root; labels at a fixed size);
  - placeholder pages for the four tabs and Settings;
  - Profile has a working Settings gear.
- **CI:**
  - `flutter-ci.yml`: generated code current (`git diff` and `git status --porcelain`), format, **`dart analyze --fatal-infos`**, tests.
- **61 tests.**

---

## Riverpod Concepts Demonstrated

- **`ProviderScope`:** the widget that holds every provider's state. It replaces three things from ConnectHub-Flutter at once:
  - get_it's container (the object graph);
  - `configureDependencies()` (no startup wiring: providers are created on first read);
  - the `BlocProvider`s that owned app-wide state.
- **Generated providers (`@riverpod`):**
  - `GoRouter appRouter(Ref ref)` becomes `appRouterProvider`;
  - the generator picks the provider type from the function's return type;
  - reads are checked at compile time.
- **Auto-dispose by default, `keepAlive` by decision:**
  - a generated provider is disposed as soon as nothing listens to it;
  - the router holds the navigation stack, so it opts out (`@Riverpod(keepAlive: true)`), and its doc comment says why;
  - a test shows the difference next to an auto-dispose provider read the same way.
- **`ref.onDispose`:** the provider that creates the router also releases it (`router.dispose`). Lifetime is declared where the object is made, not in a widget's `dispose()`.
- **`ConsumerWidget` and `ref.watch`:** `ConnectHubApp` is stateless. It watches `appRouterProvider` in `build`. ConnectHub-Flutter needed a `StatefulWidget` to create, keep and dispose its router, its session Bloc and a `Listenable`.
- **`ProviderContainer.test()`:**
  - a container for tests without widgets, disposed automatically when the test ends;
  - each container is a separate world, so each gets its own router.
- **Automatic retry, a Riverpod 3 default turned off:**
  - by default a provider that throws an `Exception` is retried up to 10 times (200 ms, 400 ms, … capped at 6.4 s);
  - while it waits, it reports **`AsyncLoading`**, with the error attached but not shown as an error;
  - every load here has a "Try again", so the app's scope passes `retry: noAutomaticRetry`;
  - two tests show both behaviours on the same failing provider;
  - a provider that wants retry will opt in with `@Riverpod(retry: …)`.
- **`riverpod_lint`:**
  - Riverpod's own lints run inside the analyzer (Riverpod 3 ships them as an `analysis_server_plugin`), so `missing_provider_scope`, `ref` misuse and others show in the IDE and in CI;
  - a probe file confirmed it: `runApp` without a `ProviderScope` was reported.

### Riverpod 3 APIs, as found on Flutter 3.47.6

The spec asked to verify these before relying on them:

| API | Found | Notes |
|---|---|---|
| `ProviderContainer.test({overrides, observers, retry})` | ✅ | Disposed by `addTearDown` |
| `Ref.mounted` | ✅ | `false` once the provider is disposed or rebuilt; used from Phase 2 after every `await` |
| `@Riverpod(keepAlive:, retry:, dependencies:)` | ✅ | Generated families come in Phase 3 (post id) |
| `ProviderScope(retry:)` | ✅ | Plus `ProviderContainer.retry` to read it back (the `main` test does) |
| Default retry | ✅, with a detail | It **skips `Error`s** (programming bugs) and retries `Exception`s. A first test threw a `StateError` and wasn't retried; the app's failures will be `AppException`s, which would be |
| `container.exists(provider)` | Deprecated in 3.5 | Use `container.read(provider.exists)` |
| `Override` | Moved | Exported from `package:flutter_riverpod/misc.dart`, not the main library |
| Legacy providers | Moved | `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider` live in `legacy.dart`; an architecture test forbids that import |

---

## Flutter / Dart Concepts Demonstrated

- **Analyzer plugins:**
  - `plugins:` in `analysis_options.yaml` makes the analyzer download, build and run the plugin;
  - **only `dart analyze` runs plugins.** `flutter analyze` skips them silently, and so does `dart analyze` on a subfolder;
  - CI uses `dart analyze --fatal-infos`, which fails on infos as `flutter analyze` does;
  - the first run builds the plugin (about 30 s), and later runs take about 12 s.
- **Running `main()` in a widget test:** `runApp` attaches to the test binding, so the real entry point is tested, not a copy of it.
- **Typed `StatefulShellRoute`** with a named navigator key per branch.

---

## Provider Graph & State Flow

```
ProviderScope (main.dart) ── retry: noAutomaticRetry
└── appRouterProvider            keepAlive · GoRouter · ref.onDispose(router.dispose)
       ▲
       └── ref.watch ── ConnectHubApp (ConsumerWidget) → MaterialApp.router(routerConfig: …)
```

State flow for navigation (the only state so far):

```
tap a tab → MainShell.goBranch(index) → GoRouter (inside appRouterProvider)
         → StatefulShellRoute shows the branch's Navigator → the tab's page
tap ⚙ on Profile → SettingsRoute().push → root Navigator covers the tabs → Back returns
```

Phase 2 adds the first real graph: the fake server and drift as `keepAlive` providers, the repositories and use cases on top, and `FeedController` (auto-dispose) watching them.

### The same foundation with Bloc (ConnectHub-Flutter)

| | ConnectHub-Flutter (Bloc) | ConnectHub Riverpod |
|---|---|---|
| Startup | `await configureDependencies()` (get_it + injectable) before `runApp` | `runApp(ProviderScope(...))`; providers are created on first read |
| The router | created in `_ConnectHubAppState`, disposed in `dispose()` | `appRouterProvider` (`keepAlive`), disposed by `ref.onDispose` |
| The root widget | a `StatefulWidget` with a `MultiBlocProvider` | a `ConsumerWidget` |
| Replacing something in a test | `getIt.registerSingleton(fake)` and `getIt.reset` in `tearDown` | `ProviderScope(overrides: [...])` or `ProviderContainer.test(overrides: [...])`; nothing global to reset |
| Lints for the pattern | `bloc_lint` not used | `riverpod_lint` in the analyzer |

---

## Data Flow

No data yet. The flow the features will follow:

```
Widget ─ref.watch─▶ Notifier ─ref.read─▶ UseCase ─▶ Repository ─▶ drift / FakeServer
  ▲                                                                   │
  └────────────── new state (AsyncValue) ◀── drift stream ◀───────────┘
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `.fvmrc`, `analysis_options.yaml`, `build.yaml` | Toolchain, strict analysis with `riverpod_lint`, lint-free generated files |
| `.github/workflows/flutter-ci.yml` | CI: generated code, format, `dart analyze`, tests |
| `lib/main.dart` | `runApp(ProviderScope(retry: noAutomaticRetry, child: ConnectHubApp()))` |
| `lib/app/connect_hub_app.dart` | `MaterialApp.router`, watching the router provider |
| `lib/app/retry_policy.dart` | `noAutomaticRetry`, and why |
| `lib/core/navigation/app_router.dart` | `appRouterProvider` (`keepAlive`) and "Page not found" |
| `lib/core/navigation/app_routes.dart` | Typed routes: the tab shell and `/settings` |
| `lib/core/design_system/` | Theme, colors, tokens, large text, state views |
| `lib/features/shell/main_shell.dart` | The four-tab `NavigationBar` |
| `lib/features/{feed,search,notifications,profile,settings}/` | Placeholder pages |
| `test/helpers/app_harness.dart` | `pumpConnectHub(tester, at:, overrides:)`; returns the scope's container |
| `test/core/navigation/app_router_test.dart` | The router provider with `ProviderContainer.test()` |
| `test/app/retry_policy_test.dart` | A failing load with and without automatic retry |
| `test/app/main_test.dart` | The real `main`: the scope and its retry policy |
| `test/app/navigation_test.dart`, `accessibility_tour_test.dart` | The app: tabs, Settings, deep links, theme; every screen at 200 % text |
| `test/architecture/architecture_test.dart` | No in-SDK Material, no legacy providers, no service locator or Bloc, one `ProviderScope` |

---

## Important Types Added

| Type | Responsibility | Layer / why there |
|---|---|---|
| `appRouterProvider` (generated from `appRouter`) | Owns the `GoRouter` for the app's lifetime | `core/navigation`: navigation is infrastructure every feature uses |
| `noAutomaticRetry` | The app's retry policy for failed providers | `app/`: an app-wide decision, passed to the root scope |
| `ConnectHubApp` (`ConsumerWidget`) | Themes and the router | `app/`: composes the app; owns nothing |
| `MainShell` | The tab bar around the active branch | `features/shell` |
| `MainShellRoute`, `FeedRoute`, …, `SettingsRoute` | Typed destinations | `core/navigation` |
| `AppTheme`, `AppColors`, `AppSpacing`, `AppRadius`, `AppIconSize`, `LargeTextContext` | The design system | `core/design_system`, ported unchanged |
| `LoadingView`, `ErrorView`, `EmptyStateView` | Full-screen states | `core/design_system/widgets` |

---

## Folder Structure Changes

```
ConnectHubRiverpod/
├── .fvmrc  analysis_options.yaml  build.yaml  LICENSE  README.md
├── .github/workflows/flutter-ci.yml
├── docs/PHASE_1_SUMMARY.md
├── lib/
│   ├── main.dart
│   ├── app/                     connect_hub_app.dart, retry_policy.dart
│   ├── core/design_system/      design_system.dart, large_text.dart, theme/, widgets/
│   ├── core/navigation/         app_routes.dart (+ .g.dart), app_router.dart (+ .g.dart)
│   └── features/                shell/, feed/, search/, notifications/, profile/, settings/
└── test/
    ├── helpers/                 pump_app.dart, app_harness.dart
    ├── app/                     main, navigation, retry policy, accessibility tour
    ├── core/                    design_system/, navigation/
    └── architecture/
```

---

## Android / iOS Comparison

| Concept | Android (MVI) | iOS (TCA) | Flutter (Bloc) | **Flutter (Riverpod)** |
|---|---|---|---|---|
| The object graph | Hilt (`@HiltAndroidApp`, modules) | `@Dependency` clients, `DependencyValues` | get_it + injectable, `configureDependencies()` | **`ProviderScope`**; providers created on first read |
| An app-lifetime object | `@Singleton` | a live `DependencyKey` value | `@lazySingleton` | **`@Riverpod(keepAlive: true)`** |
| Screen-scoped state | `ViewModel` (cleared with its screen) | a child `Store` | `BlocProvider(create:)` | **auto-dispose** (the generator's default) |
| Replacing a dependency in a test | `@TestInstallIn` / fakes | `withDependencies { … }` | `getIt.registerSingleton` | **`overrides:`** on a container or scope |
| Navigation | Navigation Compose, a `NavHost` | `NavigationStack` + `StackState` | a `GoRouter` owned by a `State` | **a `GoRouter` owned by a provider** |
| Pattern lints | Compose lints | — | — | **`riverpod_lint`** |

---

## Interview Notes

- **"What is a `ProviderScope`, and why only one?"**
  - It holds the state of every provider below it.
  - One at the root is the app's graph. Nested scopes are for overriding a provider in a subtree, which this app doesn't need.
  - An architecture test keeps it to `main.dart`.
- **"When do you use `keepAlive`?"**
  - For objects that must live as long as the app: the router (it holds navigation), and from Phase 2 the database, the server and the repositories.
  - Screen state stays auto-dispose, so leaving a screen frees it.
  - Each `keepAlive` says why next to it.
- **"How does Riverpod replace get_it?"**
  - A provider is both the registration and the lookup.
  - `ref.watch` / `ref.read` resolve dependencies at compile-time-checked call sites.
  - Tests replace providers with `overrides` on their own container, so there's no global to reset between tests.
- **"What does Riverpod 3's automatic retry do, and why turn it off?"**
  - It retries a provider that threw an `Exception`, with backoff, and reports `AsyncLoading` meanwhile.
  - For a user-facing load, that means a spinner for up to ~40 s instead of an error with "Try again".
  - Off app-wide; per provider, it's opt-in.
- **"Why doesn't `flutter analyze` show riverpod_lint's warnings?"**
  - riverpod_lint 3 is an analyzer plugin, and only `dart analyze` (and the IDE's analysis server) run plugins.
  - CI uses `dart analyze --fatal-infos`.

---

## Learning Checklist

- ✅ Pinned toolchain, strict analysis, code generation, CI
- ✅ `ProviderScope` at the root; providers generated with `@riverpod`
- ✅ `riverpod_lint` working (and why CI uses `dart analyze`)
- ✅ A `keepAlive` provider that disposes what it creates
- ✅ Tests without widgets through `ProviderContainer.test()`
- ✅ Automatic retry understood, decided and tested
- ✅ The design system, typed routes, a four-tab shell
- ✅ An accessibility tour of every screen in light and dark at 200 % text
- □ Notifiers and `AsyncValue` (Phase 2)
- □ Families (Phase 3), debounce through disposal (Phase 4)

---

## Future Improvements

- The tab badge (Phase 4) and a theme chosen in Settings (Phase 5) will be the first providers the shell and the app widget watch besides the router.
- Re-tapping the active tab can only be tested once a tab has depth (Phase 3, a post opened from the Feed lives in the root navigator; Phase 5, the profile's tabs).

---

## Notes on This Phase

- **The riverpod_lint check.**
  - The first attempt (`flutter analyze` on a path) ran for 40+ minutes before it was stopped.
  - It turned out the probe file had never been written, and `flutter analyze` doesn't run plugins anyway.
  - `dart analyze` on the whole project built the plugin in about 30 s, then reported `missing_provider_scope` on the probe and on the not-yet-wrapped `main.dart`.
  - The probe was deleted.
- **The tab labels** stay at their normal size whatever the text setting (`MediaQuery.withNoTextScaling`, as in ConnectHub-Flutter). Material's `NavigationBar` already clamps its labels to 130 %, but four labels share a phone's width and "Notifications" would still break. A test checks the labels at 200 % text, against a page body that does scale.
- **Builds:** the Android debug APK (Gradle, 109 s on a first build) and the iOS simulator app (31 s). On the iPhone 17 Pro simulator, the shell rendered in light and dark. The appearance was restored to light afterwards.
- **Mutation checks:** 24 rules broken on purpose, one at a time, each against the tests that should catch it. **All 24 caught**, three after fixes:

| Area | Mutations | Notes |
|---|---:|---|
| Riverpod | 5 | Retry scheduled; `main` without the retry policy; the router not kept alive; not disposed; starting on another tab |
| Navigation | 7 | No "not found" page; its button doing nothing; a tab's path; the destinations' order; the tapped index ignored; Settings by `go` instead of `push`; an unlabelled gear |
| Theme and design system | 10 | No dark theme; light colors in dark; a strong unread tint; a faint heart; another seed; `lerp` ignoring `t`; the large-text threshold; `ErrorView`'s retry; `EmptyStateView`'s message; tab labels scaling |
| Architecture | 2 | An in-SDK Material import; a legacy provider |

- **Three mutations survived at first and led to fixes:**
  - **Annotation mutations** (`keepAlive: false`, a route's path) seemed to survive because the runner didn't regenerate code. A provider's lifetime lives in the *generated* file (`isAutoDispose: false`). The runner now runs `build_runner` around those two, and both are caught.
  - **The seed color:** the hue test compared the primary color with `AppTheme.seedColor`, so changing the seed moved both. It now pins teal (hue 160°–190°) in both themes.
  - **The tab labels:** nothing checked their size. A new test does, and its first version was itself wrong: it used the AppBar's title as proof that the text was at 200 %, but `AppBar` clamps its title too (13.4 for 10, not 20).
