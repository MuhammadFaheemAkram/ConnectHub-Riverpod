# Roadmap

All six build phases are complete:

| Phase | Scope | Commit |
|---:|---|---|
| 1 | Riverpod foundation: `ProviderScope`, the generator and riverpod_lint, the router as a provider, the design system, a 4-tab shell, CI | `feat(riverpod): setup connecthub riverpod foundation` |
| 2 | Feed: the fake server, drift v1, repositories and use cases as providers; `FeedController` | `feat(feed): implement feed feature using riverpod` |
| 3 | Post detail (a family) and comments with likes; Create Post; drift v2 | `feat(posts): implement post details and comments using riverpod` |
| 4 | Search (debounce through disposal) and Notifications (the badge); drift v3 | `feat(search): implement search and notifications using riverpod` |
| 5 | Profiles (a family) with Saved and Undo; Settings (synchronous preferences, dynamic color, Clear cache through an epoch) | `feat(profile): implement profile and settings using riverpod` |
| 6 | Docs (the Bloc vs Riverpod comparison and guides), community files, screenshots, a release build, a final mutation pass | `docs(project): finalize connecthub riverpod architecture showcase` |

---

## Next, if the project continues

**Learning-focused (Riverpod):**
- [ ] **A `ProviderObserver`** that logs every provider update in debug builds, to compare with Bloc's `BlocObserver`.
- [ ] **Scoped overrides:** a `ProviderScope` per post card (`dependencies:` and `scoped_providers_should_specify_dependencies`), instead of passing the post down.
- [ ] **Opt-in retry** on one provider (`@Riverpod(retry: …)`), with a test of the backoff in fake time.
- [ ] **Riverpod's offline persistence** (`riverpod_sqflite`, experimental) compared with the drift cache.
- [ ] **Mutations** (Riverpod 3's experimental `Mutation` API) for the like and save buttons' pending state.

**Features (out of scope in every edition so far):**
- [ ] Follow / unfollow (the counts are the seed's).
- [ ] Edit my profile (ConnectHub-Flutter has it).
- [ ] Sign-in, with the router's gate as a provider (ConnectHub-Flutter's `AuthBloc` as a keepAlive `Notifier`).
- [ ] Chat with a realtime channel (ConnectHub-Flutter has it), to compare `emit.forEach` with stream providers.
- [ ] Live notifications (a push or a socket) into the same drift table.

**Polish:**
- [ ] Search results page by page (the server returns everything).
- [ ] Clear cache also clears the image cache.
- [ ] Localization (`intl` is already used for counts and dates).
- [ ] Integration tests on a device (`integration_test`), for the release build.

---

## Not planned

- A real backend: the fake server is the point (see [API_SIMULATION.md](API_SIMULATION.md)).
- Web and desktop: the scope is Android and iOS, like the native editions.
