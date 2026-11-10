# Learning notes

Every concept in the app, grouped, with where to see it. The phase summaries ([1](PHASE_1_SUMMARY.md) · [2](PHASE_2_SUMMARY.md) · [3](PHASE_3_SUMMARY.md) · [4](PHASE_4_SUMMARY.md) · [5](PHASE_5_SUMMARY.md) · [6](PHASE_6_SUMMARY.md)) tell the story in order; this page is the index.

---

## Riverpod

| Concept | In one line | Where |
|---|---|---|
| `ProviderScope` | holds every provider's state; one, at the root | `main.dart` |
| Generated providers | `@riverpod` on a function or class; the generator infers the kind | every `…_providers.dart`, `…_controller.dart` |
| Providers as DI | each object is a provider built from others with `ref.watch` | `di/`, `core/network/network_providers.dart` |
| `watch` / `read` / `listen` | rebuild on change / read once / react without rebuilding | [RIVERPOD_GUIDE §2](RIVERPOD_GUIDE.md#2-ref-watch-read-listen) |
| `Notifier` | synchronous state + methods | `CreatePostController`, `SettingsController`, `CurrentSearchResults` |
| `AsyncNotifier` | `Future` build; `AsyncValue` gives loading and error | `FeedController`, `PostDetailController`, `ProfileController` |
| `AsyncValue` patterns | data first, then loading, then error; `isLoading` survives invalidate | `feed_page.dart` |
| Families | one instance per parameter | `postDetailControllerProvider(id)`, `profileControllerProvider(id)`, `searchHitsProvider(query)` |
| Auto-dispose | the default; state goes with its screen | every feature provider |
| `keepAlive` | app-lifetime objects and state, each justified | repositories, `SettingsController`, `CacheEpoch` |
| `ref.onDispose` | cleanup when a provider goes | `ref.debounce`, the database, the router |
| `ref.mounted` | check after every `await` | every controller |
| `ref.invalidate` | "Try again" | the error views |
| `select` | rebuild or listen on one slice | the app root, the shell, "Mark all read" |
| Overrides | replace a provider in one container | tests; the preferences in `main` |
| `ProviderContainer.test` | a graph per test, disposed after it | `test/helpers/backend.dart` |
| Retry policy | Riverpod 3 retries by default; off here | `app/retry_policy.dart` |
| riverpod_lint | an analyzer plugin; only under `dart analyze` | `analysis_options.yaml`, CI |

**Patterns built from those:**
- **Offline-first `build`:** cached → return it + `Future(refresh)`; nothing → wait, or throw (`feed_controller.dart`).
- **`listen`, not `watch`, to patch state** from a drift stream without re-running `build` (every controller).
- **Debounce through disposal:** a family per query, and a timer cancelled in `onDispose` (`core/common/debounce.dart`).
- **A synchronous provider between an input and a family:** Riverpod 3 keeps old dependencies until a rebuild completes (`CurrentSearchResults`, §11.109).
- **Previous results without flicker:** a notifier's field survives its rebuilds (`CurrentSearchResults._shown`).
- **Combining streams with `ref.watch`** instead of `combineLatest` (`searchResultsProvider`).
- **Keeping a provider alive from a widget:** a no-op `ref.listen` (the shell and the notifications controller).
- **An epoch to reload many screens** (`CacheEpoch`), with patches ignored while reloading.
- **An async-created object** injected with `overrideWithValue` in `main` (the preferences).
- **Reading a provider outside a widget:** `ProviderScope.containerOf(context, listen: false)` in a go_router `redirect`.
- **Capturing a notifier before an `await`** in an auto-dispose provider (`SettingsTools.clearCache`).

## Flutter and Dart

| Concept | Where |
|---|---|
| `material_ui` (Material as a package), Material 3 themes from a seed | `core/design_system/theme/` |
| `ConsumerWidget` / `ConsumerStatefulWidget` | every page; `ProfileView` (a tab index) |
| `StatefulShellRoute.indexedStack` (tabs that keep their state) | `core/navigation/` |
| Typed routes (`go_router_builder`), redirects, full-screen dialogs | `app_routes.dart` |
| `PopScope` and a discard dialog (and why `go` bypasses it, §11.106) | `create_post_page.dart` |
| freezed states and sealed unions; exhaustive `switch` with patterns | `*_state.dart`, every page |
| Records and destructuring (`final (user, _) = await (…).wait`) | `ProfileController._refreshBoth` |
| `Future.wait` on a record of futures | `ProfileController` |
| A `Completer` that never completes, on purpose | `ref.debounce` |
| Infinite scroll and a footer with Retry | `features/feed/widgets/` |
| Scrolling to a new item in a lazy list (in passes, §11.107) | `post_detail_page.dart` |
| `SegmentedButton`, a radio list at large text | `settings_page.dart` |
| `TabBar` without `TabBarView` | `profile_view.dart` |
| `AboutListTile` (licenses) | `settings_page.dart` |
| `cached_network_image` with fallbacks; an offline cache in tests | `UserAvatar`, `flutter_test_config.dart` |
| Large text: `prefersStackedLayout` (stack above 130 %) | `core/design_system/large_text.dart` |
| Semantics labels, tooltips, 48 × 48 targets | design system widgets |
| `WidgetsFlutterBinding.ensureInitialized()` before `runApp` | `main.dart` |

## Data

| Concept | Where |
|---|---|
| A fake server behind API interfaces; a network simulator | `core/network/`, [API_SIMULATION.md](API_SIMULATION.md) |
| `Result` and a sealed `AppException`; `guardApiCall` | `core/common/`, `data/repository/api_guard.dart` |
| Cursor pagination (a position, not an offset) | `FakeServer.getFeed`, `FeedRepositoryImpl` |
| drift: tables, DAOs, streams, upserts not `REPLACE`, foreign keys | `core/database/` |
| `make-migrations`, schema snapshots, data-tested upgrades | `drift_schemas/`, `test/drift/` |
| Optimistic writes with exact rollback, one at a time per post | `PostRepositoryImpl` |
| A `Lock` so refresh and load-more take turns | `FeedRepositoryImpl` |
| `SharedPreferencesWithCache` with an allow-list | `core/storage/`, `SettingsRepositoryImpl` |
| dynamic_color (Android 12+), package_info_plus | `core/platform/` |

## Testing

| Concept | Where |
|---|---|
| Recording every state in order | `test/features/*/…_controller_test.dart` |
| The real graph with only its edges overridden (`realStack()`) | `test/helpers/backend.dart` |
| Hand-written fakes and gated APIs | `test/helpers/fakes/` |
| `fakeAsync` with Riverpod (`elapse(Duration.zero)`) | `test/features/search/search_controller_test.dart` |
| Whole-app widget tests at a location | `test/helpers/app_harness.dart` |
| The accessibility tour (200 % text, both themes, guidelines) | `test/app/accessibility_tour_test.dart` |
| Architecture rules as tests | `test/architecture/architecture_test.dart` |
| Migration tests with data | `test/drift/` |
| Mutation checks every phase | [TESTING.md](TESTING.md#mutation-checks) |

## Traps worth remembering

All verified in this app and recorded in the shared conventions (§11):
- **11.102:** riverpod_lint runs only under `dart analyze` of the whole project.
- **11.106:** a deep link's `go` bypasses `PopScope`.
- **11.107:** one `animateTo(maxScrollExtent)` can stop short of a lazy list's end.
- **11.108:** `make-migrations` snapshots hold raw SQL values.
- **11.109:** Riverpod 3 keeps a rebuilding provider's old dependencies until the new build completes.
- **11.110:** never complete a disposed provider's pending future with an error.
- **11.111:** in `fakeAsync`, a Riverpod rebuild needs a tick.
- **11.112:** a keepAlive provider may only use keepAlive providers.
- **11.113:** async-created objects enter through an override in `main`.
- **11.114:** the real `main()` runs once per test file, never inside `runAsync`.
- **11.115:** an epoch reload must ignore the old build's stream emissions.
- **11.116:** riverpod_generator copies a provider's doc comment into the `.g.dart`; regenerate after editing it.
- **11.30 (note):** a redirected push into a shell tab may leave the old page underneath.
- **11.98:** the main Android manifest needs INTERNET, or a release build shows no images.
