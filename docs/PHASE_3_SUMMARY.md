# Phase 3 — Post Details + Comments

## Phase Goal

Open a post, talk about it, and write new ones:
- **Post Detail** (`/posts/:postId`):
  - the full post, cached then refreshed;
  - its comments inline: add one, like one, delete your own;
  - "This post is no longer available." when the server has lost it.
- **Create Post** (`/compose`, a full-screen dialog): a 280-character counter, an optional image URL, validation, "Discard post?".
- **drift v2** (comments, with their likes) and its migration, tested with data.
- **Comment likes on the fake server:** new in this edition (Android's MVI scope has them; ConnectHub-Flutter didn't).

The Riverpod idea of the phase is the **family**: a provider with an argument. `postDetailControllerProvider('p1')` and `postDetailControllerProvider('p2')` are two controllers with their own state. Each is disposed when its page closes.

---

## What Was Implemented

- **Fake server:**
  - `getPost`, `createPost` (the client's rules, checked again: a 400 otherwise);
  - comments (oldest first; add; delete your own, or a 404);
  - **comment likes**, per user and idempotent, seeded from `FakeServer.seedCommentLikes` (below);
  - the post's `commentCount` is counted from the comments themselves.
- **APIs:**
  - `FeedApiService` gains `getPost` and `createPost`;
  - new: `CommentApiService` (list, add, delete, like) and `FakeCommentApiService`;
  - `idGeneratorProvider`: seeded in tests, so new ids repeat.
- **drift v2:**
  - `comments` (→ posts `ON DELETE CASCADE`, → users; `like_count`, `is_liked`);
  - `CommentsDao` (watch, mirror the server, add, optimistic delete with restore, optimistic like, the post's count moved in the same transaction);
  - `PostsDao` gains `watchPost`, `isCached`, `deletePost`;
  - `make-migrations`: `drift_schema_v2.json`, `app_database.steps.dart`, and `test/drift/` with a v1 → v2 test that carries real rows.
- **Data:**
  - `PostRepository` gains `watchPost`, `refreshPost` (a gone post leaves the cache too) and `createPost` (the server's copy joins the top of the feed);
  - new: `CommentRepository` (refresh, which fetches an uncached post first; add, waiting for the server; delete, optimistic; like, optimistic and one request at a time).
- **Domain:**
  - `Comment` (+ `likeCount`, `isLiked`, `isMine`);
  - eight use cases: `WatchPost`, `RefreshPost`, `CreatePost`, `WatchComments`, `RefreshComments`, `AddComment`, `DeleteComment`, `LikeComment`.
- **`signedInUserIdProvider`:** "who am I", in one place a real session would replace. Comments are *mine* by it, and a test signs in as someone else.
- **`Validators`** (shared with the server):
  - post: 1–280 characters, trimmed;
  - image URL: empty, or an absolute `http(s)` URL;
  - comment: not blank, at most 500 characters.
- **Post Detail:**
  - `cachedPostProvider(postId)` and `postCommentsProvider(postId)` (stream families);
  - `PostDetailController(postId)` (an `AsyncNotifier` family): the cache then a refresh, not found, send / like / save / like a comment / delete, effects;
  - `PostDetailPage` (a `ConsumerStatefulWidget`):
    - the post, "Comments", every comment with a like button;
    - "You" and ⋮ Delete on your own, with "Delete comment?";
    - `ComposerBar` at the bottom; the comment button focuses it;
    - sending clears the input and scrolls to the new comment.
- **Create Post:**
  - `CreatePostController` (a synchronous `Notifier`) with `CreatePostState` (validation getters);
  - `CreatePostPage`: the counter, the errors, Post with progress;
  - its own Close button, which asks "Discard post?" whenever there's a draft; `PopScope` catches the system back.
- **Design system:** `CommentTile` (with ♥ count), `ComposerBar` (+ focus node), `CharacterCounter`, `showConfirmationDialog`, `ButtonProgress`, `AppTextField`; `BackToFeedButton` for deep links.
- **Wiring:**
  - the feed's cards open their post, and its New post button opens the composer;
  - routes `/posts/:postId` and `/compose`.
- **The comment like table** (seed comments without one start at 0):

  | Comment | c1 | c2 | c3 | c5 | c7 | c12 |
  |---|---:|---:|---:|---:|---:|---:|
  | Likes | 4 | 12 | 1 | 3 | 9 | 2 |

- **337 tests.**

---

## Riverpod Concepts Demonstrated

- **Families:**
  - `@riverpod class PostDetailController … build(String postId)` generates `postDetailControllerProvider(postId)`;
  - each argument is its own provider, and two with the same argument are equal, so they share one state;
  - the generated notifier exposes the argument (`postId`);
  - ConnectHub-Flutter passed the id through get_it's `@factoryParam` and created the Cubit in a `BlocProvider`. Here the page simply watches `postDetailControllerProvider(widget.postId)`.
- **Families auto-dispose per argument:** leaving p1 disposes p1's controller and its two drift queries (`cachedPostProvider('p1')`, `postCommentsProvider('p1')`), while p2's stay. A test closes one and checks both.
- **Stream families:** `cachedPostProvider(postId)` and `postCommentsProvider(postId)` are drift queries as providers, listened to by the controller (`ref.listen`, not `watch`, as in the Feed).
- **`AsyncError` with a specific exception as a state:**
  - "no longer available" is `AsyncError(NotFoundException())`;
  - the page matches it with a pattern (`AsyncError(error: NotFoundException())`) before the generic error;
  - no separate `notFound` case in the state.
- **A synchronous `Notifier` for a form:** `CreatePostController.build()` returns the empty form, and `submit()` tracks its own progress in `status`. The page closes on success from `ref.listen(…select((form) => form.status))`, never from `build`.
- **`ConsumerStatefulWidget`:** Post Detail keeps three UI objects (the input's controller, the scroll controller, the focus node) and still has `ref` everywhere in its `State`.
- **Two effects from one state:** a message (SnackBar, consumed) and `sentCount` (clear the input, scroll), each from its own `select`.
- **A provider for "who am I":** `signedInUserIdProvider` feeds the comment repository. Overriding it (`'u_grace'`) makes Grace's comments *mine*: a test, and the seam a real session would plug into.
- **Providers depending on providers:** `commentRepositoryProvider` watches `postRepositoryProvider` (to fetch an uncached post before its comments). Still one `ref.watch` each, and checked at compile time.

---

## Flutter / Dart Concepts Demonstrated

- **drift migrations with `make-migrations`:**
  - exported schemas (`drift_schemas/`), a generated `stepByStep` (`app_database.steps.dart`), and generated schema snapshots for tests;
  - the snapshots hold raw SQL values: dates as ISO-8601 text, booleans as 0 / 1;
  - the data test carries a cached feed and a save across v1 → v2, then caches a comment and checks its cascade.
- **`PopScope` vs `go()`:** `PopScope` only sees pops. A deep-linked composer's Back went to the feed with `go`, which no `PopScope` sees, and lost the draft unasked. The accessibility tour found it. The composer now has its own Close button that asks first.
- **The system back gesture in a test:** `tester.binding.handlePopRoute()`.
- **Lazy lists and "scroll to the end":** a lazy `ListView` only estimates its full height until its last items are built. One `animateTo(maxScrollExtent)` stopped short on the simulator (keyboard up), so the page now scrolls in up to three passes, re-reading the end each time. A widget test with a long thread checks the new comment ends up on screen.
- **`(future1, future2).wait`:** the post and its comments refresh side by side.

---

## Provider Graph & State Flow

```
PostDetailPage(postId)
  └─ postDetailControllerProvider(postId)     auto-dispose family   AsyncNotifier<PostDetailState>
       ├─ listen cachedPostProvider(postId)    auto-dispose family   Stream<Post?>
       ├─ listen postCommentsProvider(postId)  auto-dispose family   Stream<List<Comment>>
       └─ read  watchPost · refreshPost · watchComments · refreshComments · addComment
                · deleteComment · likeComment · likePost · savePost  UseCaseProviders
            ├─ postRepositoryProvider          keepAlive   (+ feedDao: a new post joins the feed)
            └─ commentRepositoryProvider       keepAlive   likes in flight
                 ├─ commentApiServiceProvider  keepAlive   FakeCommentApiService
                 ├─ postRepositoryProvider     (fetches an uncached post first)
                 └─ signedInUserIdProvider     keepAlive   'u_demo'
CreatePostPage
  └─ createPostControllerProvider             auto-dispose   Notifier<CreatePostState>
       └─ read createPostUseCaseProvider → postRepositoryProvider
```

**Opening a post from the feed:**

```
tap a card → PostDetailRoute(postId).push → PostDetailPage watches postDetailControllerProvider(postId)
  → build: listen(post, comments); the post is cached → AsyncData(post, comments) at once
  → Future(refresh): (refreshPost, refreshComments).wait → drift → listeners patch the state
```

**A comment:**

```
Send → sendComment(text) → isSending: true (Send shows progress)
  → AddCommentUseCase → CommentRepository → API → drift (comment + the post's count, one transaction)
  → read the comments → comments + sentCount + 1, isSending: false
  → ref.listen(sentCount) → clear the input, scroll to the end
  → the feed's card (another screen, the same drift row) shows "4 comments"
```

### Post Detail with Bloc and with Riverpod

| | ConnectHub-Flutter | ConnectHub Riverpod |
|---|---|---|
| The post id | `getIt<PostDetailCubit>(param1: postId)` (`@factoryParam`) | `postDetailControllerProvider(postId)` (a family) |
| Two streams | two `StreamSubscription`s, cancelled in `close()` | two `ref.listen`s on stream families, removed on dispose |
| Not found | a `PostDetailState.notFound()` case | `AsyncError(NotFoundException())`, matched by pattern |
| Comments | a preview here, all on a separate Comments screen | all inline (the Android edition's layout); comment likes |
| The form | `CreatePostCubit` + `BlocConsumer` | `CreatePostController` (`Notifier`) + `ref.listen` |

---

## Data Flow

```
PostDetailPage ─watch─▶ PostDetailController(postId) ─read─▶ UseCases ─▶ PostRepository / CommentRepository
      ▲                         ▲                                              │
      │                         └─ listen ─ cachedPost(postId), postComments(postId) ◀─ drift ◀─┤
      └── AsyncValue<PostDetailState> ◀──────────────────────────────────────────────────────┘
                                         FeedApiService / CommentApiService ─▶ FakeServer
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `lib/core/network/api/comment_api_service.dart`, `fake_comment_api_service.dart` | The comment endpoints |
| `lib/core/common/validators.dart`, `id_generator.dart`, `session_providers.dart`, `form_status.dart` | Rules, ids, "who am I", a form's status |
| `lib/core/database/tables/comments_table.dart`, `daos/comments_dao.dart` | drift v2 |
| `lib/core/database/app_database.steps.dart`, `drift_schemas/app_database/drift_schema_v2.json` | The migration, generated |
| `lib/data/repository/comment_repository_impl.dart`, `mapper/comment_mappers.dart` | Comments, offline-first |
| `lib/domain/model/comment.dart`, `repository/comment_repository.dart`, eight use cases | The domain |
| `lib/features/post_detail/` | `post_detail_controller.dart` (+ the two stream families), `post_detail_state.dart`, `post_detail_page.dart` |
| `lib/features/create_post/` | `create_post_controller.dart`, `create_post_state.dart`, `create_post_page.dart` |
| `lib/core/design_system/widgets/comment_tile.dart`, `composer_bar.dart`, … | Shared widgets |
| `lib/core/navigation/back_to_feed_button.dart` | Back from a deep link |
| `test/drift/app_database/` | The migration tests and schema snapshots |
| `test/features/post_detail/`, `test/features/create_post/` | Controllers, pages, flows |

---

## Important Types Added

| Type | Responsibility | Layer / why there |
|---|---|---|
| `Comment` | A comment as the user sees it | `domain/model` |
| `CommentRepository` / `CommentRepositoryImpl` | Cached comments, optimistic delete and like | domain contract / data implementation |
| `CommentApiService` / `FakeCommentApiService` | The wire | `core/network` |
| `CommentsDao`, `CachedComment`, `CommentLikeState` | The cache and its counts | `core/database` |
| `PostDetailController` (family) | One post's screen state | `features/post_detail` |
| `cachedPostProvider`, `postCommentsProvider` (families) | Live drift queries per post | `features/post_detail` |
| `PostDetailState` | The post, its comments, sending, effects | `features/post_detail` |
| `CreatePostController`, `CreatePostState` | The form | `features/create_post` |
| `Validators` | Shared rules | `core/common`: the client and the server |
| `signedInUserIdProvider`, `idGeneratorProvider` | Identity and ids | `core/common`, `core/network` |
| `CommentTile`, `ComposerBar`, `CharacterCounter`, `showConfirmationDialog` | Shared widgets | `core/design_system` |

---

## Folder Structure Changes

```
lib/
├── core/common/            + validators, id_generator, session_providers, form_status
├── core/database/          + tables/comments_table, daos/comments_dao, app_database.steps
├── core/network/api/       + comment_api_service, fake_comment_api_service
├── core/navigation/        + back_to_feed_button
├── data/                   + mapper/comment_mappers, repository/comment_repository_impl
├── domain/                 + model/comment, repository/comment_repository, 8 use cases
└── features/               + post_detail/, create_post/
drift_schemas/app_database/ + drift_schema_v2.json
test/drift/app_database/    migration_test.dart, generated/ (schema snapshots)
```

---

## Android / iOS Comparison

| Concept | Android (MVI) | iOS (TCA) | Flutter (Bloc) | **Flutter (Riverpod)** |
|---|---|---|---|---|
| A screen per id | `SavedStateHandle["postId"]` in the ViewModel | a `Store` scoped with the id in `State` | `@factoryParam` | **a family: `provider(postId)`** |
| Comments | inline, with likes | — | a separate screen | **inline, with likes** |
| Not found | a `NotFound` state | a `notFound` case | `PostDetailState.notFound()` | **`AsyncError(NotFoundException())`** |
| Create post | — | a sheet, `@Presents` | a full-screen dialog + `PopScope` | **a full-screen dialog; its own Close + `PopScope`** |
| Migrations | Room `AutoMigration` + tests | SwiftData `VersionedSchema` | drift `make-migrations` | **the same** |

---

## Interview Notes

- **"What is a family, and when do you use one?"**
  - A provider with an argument, for state that depends on a parameter: one post, one user, one search query.
  - Each argument gets its own instance and lifetime, and equal arguments share one.
- **"How does auto-dispose behave with families?"**
  - Per argument: closing post p1 disposes p1's controller and its streams; p2's live on.
  - That's why a family's argument should be small and comparable (a string id, not a whole object).
- **"How do you model 'not found'?"**
  - As an `AsyncError` with the domain's `NotFoundException`, matched by pattern in the page.
  - No extra state case: `AsyncValue` already says "failed", and the exception says why.
- **"How do you navigate after a notifier finishes something?"**
  - The notifier only sets state (`status: success`).
  - The page reacts in `ref.listen` and navigates. Never in `build`, and never from the notifier, which has no `BuildContext`.
- **"How do you test a migration?"**
  - Export each schema version, generate the snapshots, run `migrateAndValidate` from every version.
  - For data: insert rows into the old snapshot, migrate, and compare with the new one.

---

## Learning Checklist

- ✅ Families: an `AsyncNotifier` and two stream providers per post id
- ✅ Per-argument auto-dispose, proven by a test
- ✅ "Not found" as `AsyncError(NotFoundException())`
- ✅ A synchronous `Notifier` for a form; navigation from `ref.listen`
- ✅ `ConsumerStatefulWidget` for UI objects; two effects from two `select`s
- ✅ drift v2 with a generated, data-tested migration
- ✅ Optimistic comment delete and like with rollback; a comment that updates the feed's count
- □ Debounce through disposal (Phase 4)
- □ Families for profiles (Phase 5)

---

## Future Improvements

- Authors' names and avatars open their profiles in Phase 5 (`/users/:userId`).
- Comments load all at once; a long thread would page them like the feed.
- Editing a post or a comment is out of scope in every edition.

---

## Notes on This Phase

- **The accessibility tour found a bug:**
  - "Discard post?" on a deep-linked composer: its Back (`BackToFeedButton`) used `go`, which `PopScope` never sees, so a draft was thrown away without asking;
  - the composer now has its own Close button that asks;
  - a page test covers the link, and another the system back gesture.
- **The simulator found a bug:** after sending a comment on a long post with the keyboard up, the list stopped short of the new comment (a lazy list's estimated height). The page now scrolls in passes, and a widget test with twelve comments checks it.
- **Simulator check (iPhone 17 Pro):**
  - the feed, a post with its comments and their likes;
  - a comment sent: the count went from 3 to 4, the input cleared, the new comment showed as "You" at the end;
  - light and dark; the appearance, text size and status bar restored afterwards.
- **Builds:** the Android debug APK and the iOS simulator app.
- **Mutation checks:** 49 rules broken on purpose, one at a time, each against the tests that should catch it. **All 49 caught**, one after a better test:

| Area | Mutations | Notes |
|---|---:|---|
| Fake server and validators | 10 | Comment likes counted and seeded; only the author deletes; the comment rules; comments oldest first; a new post trimmed; counts derived; the limits (280, 500) and the URL scheme |
| drift | 7 | Comments oldest first; a refresh removing stale comments; the count never below zero; an added comment counted; a comment like's count; no comment for an uncached post; the migration step |
| Repositories and providers | 9 | A gone post leaves the cache; a new post joins the feed; an uncached post fetched before its comments; a failed delete restored; a comment like rolled back and one at a time; *mine*; the signed-in user from its provider; an empty image URL sent as none |
| PostDetailController | 10 | The refresh behind the cache; "no longer available"; the comments' failure; `sentCount`; a second send and a blank one ignored; live post updates; a comment like's direction; the delete's message; `ref.mounted` |
| Create Post | 6 | No double post; the error cleared by editing; no error on an untouched form; closing after posting; Close and the back gesture asking about a draft |
| Pages and widgets | 7 | The input cleared; "no longer available" without Try again; the comment button focusing the input; Delete asking first; scrolling to the new comment; the feed opening a post; the comment like's labels |

- **The one that survived at first:** scrolling in a single pass. The first scroll test had comments of similar heights and no keyboard, so one pass reached the end. With the keyboard up (a bottom view inset) and short comments above long ones, the list underestimates as it did on the simulator, and the single pass fails.
