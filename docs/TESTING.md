# Testing

**498 tests**, all run by `fvm flutter test` in about 25 seconds, with no device, no network and no real time waited. CI runs them on every push, after checking the generated code, the format and `dart analyze --fatal-infos` (which also runs riverpod_lint).

```bash
fvm flutter test                                   # everything
fvm flutter test test/features/search              # one area
fvm flutter test --plain-name 'debounce'           # by name
```

---

## The layers

| Area | Folder | What it proves |
|---|---|---|
| Fake server | `test/core/network/` | the server's rules: paging by cursor, idempotent likes, own comments only, search order, read states, users, saved posts |
| drift | `test/core/database/`, `test/drift/` | DAOs (upserts, cascades, the feed window, Clear cache), and every migration path with data (v1 → v2 → v3) |
| Repositories | `test/data/` | on the real server and drift: offline-first refresh, optimistic writes with exact rollback, one write at a time, settings persistence through the real `SharedPreferencesWithCache` |
| The provider graph | `test/di/` | the real graph builds; an override reaches everything above it, in one container only; what is kept alive |
| Notifiers | `test/features/*/…_controller_test.dart` | every state in order, on fakes or the real stack |
| Pages and flows | `test/features/*/…_page_test.dart`, `…_flow_test.dart` | each page in each state; flows across screens on the real stack |
| The app | `test/app/` | `main()` itself; navigation; the retry policy; the accessibility tour |
| Rules | `test/architecture/`, `test/platform/` | the layer boundaries; the release manifest asks for the network |

---

## Notifiers: every state, in order

```dart
container = testContainer(overrides: [
  feedRepositoryProvider.overrideWithValue(feed),       // a hand-written fake
  postRepositoryProvider.overrideWithValue(posts),
]);
container.listen(feedControllerProvider, (_, next) => states.add(describe(next)),
    fireImmediately: true);

await pumpEventQueue();
expect(states, ['loading', 'data p1,p2', 'data p3,p1,p2']);
```

- **`testContainer()`:** `ProviderContainer.test(retry: noAutomaticRetry, overrides: …)`, disposed after the test.
- **The first listener creates the notifier**, as a screen would.
- **`describe`** turns each `AsyncValue` into a short string (`'loading'`, `'data p1,p2 "message"'`, `'error NetworkException'`), so the expectation reads like a timeline. It checks `isLoading` before the error, as the pages do.
- **This is `bloc_test`'s idea:** the container plays `build:`, `container.listen` plays `expect:`.
- **Gates:** fakes with a `Completer` (`feed.gate`) hold an answer back, to see the in-between states ("loading until the server answers", "the screen closed mid-request").

---

## The real stack

`realStack()` (`test/helpers/backend.dart`) overrides only the edges of the real graph:

| Override | Value |
|---|---|
| `clockProvider` | a fixed clock |
| `idGeneratorProvider` | seeded ids |
| `networkSimulatorProvider` | `NetworkSimulator(latencyFactor: 0)`: instant answers |
| `databaseConnectionProvider` | `NativeDatabase.memory()` |
| `preferencesStoreProvider` | `MemoryPreferencesStore` |
| `platformColorSchemesProvider` | no wallpaper colors (or given ones) |
| `appVersionProvider` | `'1.0.0 (1)'` |

Everything else is the app's own code. `DataStack` (`test/helpers/data_stack.dart`) wraps a container with shortcuts to the server, the database and the repositories.

---

## Widgets and flows

```dart
final container = await pumpConnectHub(tester, at: '/posts/p16', overrides: realStack());
await tester.tapAndSettle(find.text('Demo User').first);
expect(tester.selectedTab, 3);
expect(container.read(appRouterProvider).canPop(), isFalse);
```

- **`pumpConnectHub`** (`test/helpers/app_harness.dart`) pumps the whole app in a `ProviderScope` at a location, on a phone-sized surface (390 × 844), and returns the container.
- **Pages in isolation:** the same harness with one repository overridden by a fake (the Search page with a `FakeSearchRepository`).
- **Flows on the real stack:**
  - a like on the feed shows on the detail and the profile;
  - a comment updates the feed's count;
  - a like in search results updates the feed;
  - Clear cache keeps saved posts;
  - network failure → error → recovery.
- **No theme flash:** the app is pumped once with "dark" stored, and the very first frame is dark.
- **`main()` itself:** one test awaits the real `main()` (in-memory platform preferences) and checks the injected store and the retry policy. It runs once per file, because it opens a real database (§11.114).

---

## Fake time

- Search's debounce is tested in `fakeAsync` with a fake repository: three keystrokes 100 ms apart, one search, no timer left.
- Riverpod's rebuilds run on a scheduler tick, so tests `async.elapse(Duration.zero)` rather than only flushing microtasks (§11.111).
- drift and fake time don't mix (§11.27), so tests that need drift run in real (but instant) time with `pumpEventQueue()`.

---

## The accessibility tour

`test/app/accessibility_tour_test.dart` visits every screen and key state in light and dark at 200 % text, and checks:
- no overflow (an overflow fails the test);
- Flutter's `androidTapTargetGuideline` (48 × 48), `labeledTapTargetGuideline` and `textContrastGuideline`.

New screens and states are added to it.

---

## Images

`test/flutter_test_config.dart` gives every test an offline image cache: tests have no network, and the default cache would fail asynchronously while looking for a temporary directory. Images show their fallbacks (initials, a plain box), as they would offline.

---

## Mutation checks

Every phase ended with a **mutation pass**: a script breaks one rule at a time in `lib/` (a condition flipped, a guard removed, a lifetime changed), runs the relevant tests, and expects them to fail.
- A mutation that survives means a missing test, and the test is added.
- Mutating an annotation (`@Riverpod(keepAlive: …)`, `@TypedGoRoute`) needs a `build_runner` run, because a provider's lifetime lives in the generated file.

| Phase | Mutations | Caught first | Notes |
|---|---:|---:|---|
| 1 Foundation | 24 | 24 | |
| 2 Feed | 43 | 40 | a tie-break test, a connection-only database override, a `SynchronousFuture` fake |
| 3 Post detail, comments, create | 49 | 48 | a keyboard-up scroll test |
| 4 Search, notifications | 39 | 39 | |
| 5 Profile, settings | 33 | 29 | Clear cache keeps me; no empty feed while reloading; my id leaves nothing underneath; Cancel clears nothing |
| 6 Final pass (the whole suite) | 22 | 17 | a pull to refresh answered after the Feed is gone; notifications, a post, a profile and a search each reloading through a real Clear cache |

Each phase summary lists its mutations.

---

## Rules for writing tests

- **Bound every wait:** `pumpAndSettle` with a duration where something animates forever; `pumpEventQueue()` instead of sleeps.
- **Fakes over mocks:** hand-written fakes in `test/helpers/fakes/` (repositories, gated APIs, preferences). No mocking library.
- **Record, then assert:** a list of every state beats checking only the last one; regressions hide in the middle.
- **Find what a user sees:** text, tooltips (`find.byTooltip('Settings')`) and semantics labels, not widget types where possible.
- **Scroll before tapping** below the fold (`ensureVisible`): a tap outside the surface misses silently (§11.51).
