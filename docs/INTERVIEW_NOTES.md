# Interview notes

Questions this project can answer, with short answers and where to look. Grouped from "explain the basics" to "what went wrong".

---

## Riverpod basics

**What is a provider?**
- A declared, lazily created value: an object, a stream, a future, or a notifier with state.
- Its current value lives in a `ProviderScope` (or a `ProviderContainer` in tests), not in a global.

**`ref.watch`, `ref.read`, `ref.listen`: when do you use each?**
- `watch` in `build`, to rebuild when the dependency changes.
- `read` in methods and callbacks, to use a value once.
- `listen` to react without rebuilding: show a SnackBar, or patch a notifier's state from a stream without re-running its `build`.

**`Notifier` or `AsyncNotifier`?**
- `AsyncNotifier` when the first state needs an `await` (a screen that loads): `AsyncValue` gives loading and error for free.
- `Notifier` when the state is ready at once: a form, the search query, the settings (synchronous on purpose, so the theme doesn't flash).

**What's a family?**
- A provider with a parameter: one instance per value, cached and disposed separately.
- Here: a post by id, a profile by id, a search by query.

**Auto-dispose or keepAlive?**
- Auto-dispose by default: a screen's state goes with the screen.
- keepAlive for app-lifetime objects (database, repositories, router) and app-wide state (settings, the cache epoch), each with a comment saying why.

## Design questions

**Why use Riverpod for DI too, instead of get_it?**
- One graph for objects and state.
- Overrides replace any object in one container, so tests run the real graph with only its edges faked (`realStack()`).
- No global state: two tests can't see each other.
- No "not registered" runtime error.
- **The cost:** the wiring is written by hand (injectable generated it).

**How do you get an object that needs an `await` into the graph?**
- Give its provider no real default: it throws a clear error.
- `await` the object in `main`, and `overrideWithValue` it in the root `ProviderScope`. Everything below reads it synchronously.
- This is how the preferences are opened before the first frame.

**How do you avoid a theme flash?**
- The settings notifier is synchronous and reads a store opened before `runApp`, so `MaterialApp` has the saved theme on its first build.
- A test pumps the app once with "dark" stored and checks the first frame.

**How is the app offline-first?**
- Screens read only drift.
- A controller's `build` returns the cache at once and refreshes behind it.
- Repositories write drift first and the server second, rolling back on failure.
- One drift row per post means a like shows on every screen.

**How do you make every screen reload after Clear cache?**
- A keepAlive counter provider (the epoch) that every server-data controller `watch`es. Clear cache bumps it, and they all rebuild.
- Each controller ignores drift's emissions while reloading, so the emptied tables never flash on screen.

**Where do optimistic updates live?** In the repositories, so every screen that likes or saves shares one rollback path. Notifiers only report a failure.

**How do you handle effects (SnackBars, navigation) with Riverpod?**
- The notifier puts a value in its state (a message, a counter); the widget `ref.listen`s to it, acts once, and calls `messageShown()`.
- Never in `build`, and notifiers never see `BuildContext`.

## Search

**How do you debounce a search with Riverpod?**
- A family keyed by the query waits 300 ms with a timer cancelled in `ref.onDispose`.
- Typing on makes the screen watch another key, so the old provider is disposed and its wait never ends. The newest query wins because it's the only one still watched.

**Why did the first version search every keystroke?**
- Riverpod 3 keeps a rebuilding provider's previous dependencies (paused) until its new build completes.
- The provider watching the query was async and took the whole debounce to complete, so every older query stayed alive.
- A synchronous provider in between lets go at once. A test types "a", "ad", "ada" and expects one search.

**Why does the cancelled wait never complete?**
- Completing it with an error after the provider is gone leaves nobody to handle the error, so it surfaces as uncaught.
- A future nobody waits for is simply collected.

**How do you keep the old results on screen while the next query loads?**
- The synchronous notifier remembers the last results in a field (fields survive rebuilds), and returns "searching, with these previous results".

## Testing

**How do you test a notifier?**
- A `ProviderContainer.test` with fakes or the real stack, `container.listen` from the start, and a list of every state in order, each turned into a short string. It's `bloc_test` without the package.

**How do you test that disposal cancels work?**
- Close the listener mid-request and check that nothing throws, and that no timer is left. `flutter_test` fails on pending timers.

**How do you know your tests are good?**
- A mutation pass every phase: break one rule at a time and check that a test fails.
- Survivors became tests. Phase 5's four survivors became three new tests and one stronger one.

**Testing a widget that reads providers?** Pump it inside a `ProviderScope` with overrides. Here it's the whole app at a location (`pumpConnectHub(at: '/posts/p1')`), so routes and providers are real.

## What went wrong (good stories)

- **Every keystroke searched** (the previous-dependencies rule above), found by a cancellation test.
- **A redirected push of my own profile:**
  - it didn't crash, as the shared conventions predicted for this setup; instead it left the post underneath the Profile tab;
  - a mutation survived because the test only checked the tab, so the test now checks `router.canPop()`.
- **Clear cache flashed an empty feed:**
  - between the epoch bump and the reload, drift emitted the emptied tables;
  - every controller now ignores patches while `isLoading`, and a test records the states.
- **The settings notifier and the lint:** riverpod_lint flagged a keepAlive notifier reading auto-dispose use cases.
- **The real `main()` in tests:** run inside `runAsync`, the app's animations failed (real and fake clocks disagreed), and a second run opened a second database. Now it runs once, in fake time.
- **A release-only bug:** the main Android manifest had no INTERNET permission (debug manifests add it), so a release build would have shown no images. A test now reads the manifest.

## Bloc vs Riverpod

**Which would you pick, and why?** It depends; the full comparison is in [BLOC_VS_RIVERPOD.md](BLOC_VS_RIVERPOD.md).
- **Bloc:** when explicit, loggable events and rich concurrency rules (droppable, sequential) matter, or the team knows MVI.
- **Riverpod:** when much of the state is derived (live search results, a profile per id), and when one tool for DI and state that tests can override is worth learning its rules.

**What does Riverpod do that Bloc doesn't?** Families with automatic disposal, composition with `ref.watch`, overrides without a locator.

**What does Bloc do that Riverpod doesn't?** Event transformers (`restartable`, `droppable`), and a single class per screen with every change an event, which makes logging and code review simple.

**How does this map onto MVI and TCA?**
- Notifier methods are the intents/actions; `state` is the single rendered value; `ref.listen` is the effect channel; providers are Hilt / `@Dependency`.
- Riverpod has no reducer: methods change `state` directly.
