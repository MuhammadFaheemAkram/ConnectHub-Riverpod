<!-- Thanks for contributing to ConnectHub Riverpod! -->

## Summary

<!-- What does this PR change, and why? -->

## Changes

-

## Checklist

- [ ] `fvm dart analyze --fatal-infos` reports no issues (it also runs riverpod_lint; `flutter analyze` doesn't).
- [ ] `fvm dart format --output=none --set-exit-if-changed .` passes.
- [ ] `fvm flutter test` passes; new logic is covered by tests where practical.
- [ ] Generated code is regenerated and committed (`fvm dart run build_runner build`).
- [ ] Architecture boundaries are respected (Widget → Notifier → UseCase → Repository), and screens read only the cache.
- [ ] New providers are auto-dispose unless a comment justifies `keepAlive`; notifiers check `ref.mounted` after every `await`; no effects in `build`.
- [ ] A schema change bumps `schemaVersion` and ships with `make-migrations` output and a migration test.
- [ ] UI changes work in dark mode and at large text sizes, and new screens or states are added to the accessibility tour.
- [ ] Docs are updated if behaviour or structure changed (including `docs/PROVIDER_GRAPH.md` for new providers).
- [ ] Commit messages follow Conventional Commits.

## Screenshots (if UI changed)

| Before | After |
|--------|-------|
|        |       |
