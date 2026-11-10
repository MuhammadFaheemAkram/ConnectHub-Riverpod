# Contributing to ConnectHub Riverpod

Thanks for your interest! This is a learning-focused reference project: the Riverpod edition of [ConnectHub-Flutter](https://github.com/MuhammadFaheemAkram/ConnectHub-Flutter). Contributions that improve clarity, correctness or teaching value are especially welcome, and so are fair additions to the Bloc vs Riverpod comparison.

## Ground Rules

- Be respectful. See the [Code of Conduct](CODE_OF_CONDUCT.md).
- **Keep the architecture intact:**
  - Respect the layer boundaries: Widget → Notifier → UseCase → Repository → API service / drift.
  - `domain/` stays pure Dart (no Flutter, no Riverpod); features never import `data/`, `core/network` or `core/database`; drift files never import `material_ui`.
  - **Screens read only the cache.** Repositories refresh drift from the API, and they own the optimistic writes and their rollback.
  - **Providers are the DI.** No service locator, no global singletons: every object is a provider, and tests replace it with `overrides`.
- **Riverpod rules** (the spec's Correctness Rules):
  - `ref.watch` in `build`, `ref.read` in methods, `ref.listen` for effects;
  - `if (!ref.mounted) return;` after every `await` in a notifier;
  - no effects in `build`;
  - auto-dispose by default; every `keepAlive` has a comment saying why;
  - no legacy providers (`StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`);
  - no automatic retry unless a provider opts in, with a reason.
- **UI:** import `package:material_ui/material_ui.dart`, never `package:flutter/material.dart`.
- **Dependencies:** keep them few and mainstream, and explain each new one in the README's tech stack.

`test/architecture/architecture_test.dart` checks most of these.

## Development Setup

- Install [FVM](https://fvm.app), then run `fvm install`. It reads `.fvmrc`, which pins Flutter 3.47.6.
- iOS needs Xcode. Android needs the Android SDK and Java 17+ (Android Studio's bundled JDK works).
- Get the packages with `fvm flutter pub get`, then start the app with `fvm flutter run`. The demo user is always signed in.
- After changing annotated code (`@riverpod`, freezed, json_serializable, drift, typed routes), regenerate it:

  ```bash
  fvm dart run build_runner build
  ```

  Generated files are committed, and CI fails if they are stale. A provider's lifetime (`keepAlive`) lives in the generated file, so regenerate after changing an annotation.
- **Changing the database schema:**
  1. Bump `schemaVersion` in `app_database.dart`.
  2. Run `fvm dart run drift_dev make-migrations`. It exports the new version to `drift_schemas/` and regenerates the steps and the migration test.
  3. Write the new step in `stepByStep`.
  4. Add a data test in `test/drift/` for anything that moves data.

## Coding Conventions

- **Analysis:** `fvm dart analyze --fatal-infos` must report **no issues**. Use `dart analyze` of the whole project, not `flutter analyze`: only `dart analyze` runs the riverpod_lint plugin.
- **Formatting:** `fvm dart format .` (the tall style).
- **One notifier per screen**, named `…Controller`; its state is a freezed class, rendered with an exhaustive `switch`.
- **`AsyncValue` order in widgets:** data first, then `isLoading`, then the error.
- **Accessibility:** every tappable is at least 48 × 48 and has a label, and text contrast meets WCAG AA in both themes. Above 130 % text (`context.prefersStackedLayout`), side-by-side controls stack. The accessibility tour (`test/app/accessibility_tour_test.dart`) checks all of this, so add new screens and states to it.
- **Comments** explain *architecture decisions* and Riverpod choices, not obvious code.

## Commits

This project uses **[Conventional Commits](https://www.conventionalcommits.org/)**:

```
<type>(<scope>): <message>
```

Examples: `feat(search): add a people-only scope`, `test(feed): cover a failed second page`, `docs(project): update the provider graph`.

## Pull Requests

1. Fork the repository and create a topic branch.
2. Make sure `fvm dart analyze --fatal-infos`, `fvm dart format --output=none --set-exit-if-changed .` and `fvm flutter test` all pass.
3. Update or add documentation where relevant (a new provider goes into `docs/PROVIDER_GRAPH.md`).
4. Open a PR with a clear description of the change and its motivation.

## Tests

- **Notifiers:** `ProviderContainer.test` (`testContainer()` in `test/helpers/backend.dart`), `container.listen` from the start, and every state recorded in order.
- **The real stack:** `realStack()` overrides only the edges (clock, ids, latency 0, drift in memory, preferences in memory).
- **Fakes over mocks:** hand-written fakes in `test/helpers/fakes/`; no mocking library.
- **Widgets and flows:** `pumpConnectHub(tester, at: …, overrides: …)`.
- **Every async wait must be bounded.** See [docs/TESTING.md](docs/TESTING.md).
