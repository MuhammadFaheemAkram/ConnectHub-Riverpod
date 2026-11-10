# Side effects

How the app handles what isn't state: SnackBars, clearing a field, navigation, writes that may fail, work that outlives its screen, retries. The rules are the spec's Correctness Rules; this page shows where each one lives.

---

## 1. Effects through `ref.listen`, consumed once

A notifier never touches `BuildContext`. When something should *happen* (a SnackBar), it puts a value in its state, and the widget reacts to that value once.

```dart
// The notifier (FeedController): set the message…
_update((feed) => feed.copyWith(message: likeFailedMessage));
void messageShown() => _update((feed) => feed.copyWith(message: null));

// …the widget (FeedPage): show it, then consume it.
ref.listen(feedControllerProvider.select((feed) => feed.value?.message), (_, message) {
  if (message == null) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
  ref.read(feedControllerProvider.notifier).messageShown();
});
```

- **`ref.listen`, never `build`:** `build` can run many times for one state; the callback runs once per change.
- **`select`:** the listener runs only when the message changes, not on every like or page.
- **`messageShown()` clears it:** the same text can then come back later and show again. ConnectHub-Flutter gave each `UiMessage` an id for the same purpose.

**The other effects:**

| Effect | State | Widget reaction |
|---|---|---|
| A sent comment clears the field and scrolls to it | `PostDetailState.sentCount` (a counter) | `ref.listen(…select((d) => d.value?.sentCount ?? 0))`: when it grows, clear and scroll (in up to 3 passes: a lazy list underestimates its end, §11.107) |
| A created post closes the composer | `CreatePostState.status` (`FormStatus.success`) | `ref.listen(…select((form) => form.status))`: close |
| Removed from saved, with Undo | `SavedPostsState.message` + `undoable` | a SnackBar with an Undo action → `controller.undo(post)` |
| Clear cache done | `SettingsToolsState.message` | a SnackBar |

---

## 2. `ref.mounted` after every `await`

A notifier can be disposed while it waits: the user leaves the screen during a request. Touching `state` (or `ref`) afterwards throws.

```dart
Future<void> refresh() async {
  if (!ref.mounted) return;
  final result = await ref.read(refreshFeedUseCaseProvider)();
  if (!ref.mounted) return;          // the Feed was closed meanwhile
  …
}
```

- Every controller checks after each `await`. Tests close the screen mid-request and check nothing throws ("a late answer after the Feed is gone").
- **Capture what must outlive the screen before the `await`:**
  - `SettingsTools.clearCache` reads `cacheEpochProvider.notifier` first;
  - if Settings closes while the cache clears, the app-wide bump still happens, through the captured notifier;
  - a test closes the listener mid-clear.

---

## 3. Optimistic writes, in the repositories

Likes, saves, comment likes, deleted comments and read notifications change **drift first**, then ask the server, and roll back if it refuses. The notifiers don't do any of this: they call the use case and only report a failure.

```dart
// PostRepositoryImpl.setLiked
return _oneAtATime('like:$postId', () async {
  final before = await _posts.applyLike(postId, liked: liked);     // 1. drift at once
  final result = await guardApiCall(() => _api.setLiked(postId, liked: liked));
  switch (result) {
    case Ok(value: final post):
      await _posts.writeLike(postId, (isLiked: post.isLiked, likeCount: post.likeCount));   // 2a. the server's numbers
      return const Ok(null);
    case Err(:final exception):
      if (before != null) await _posts.writeLike(postId, before);  // 2b. exactly what was there
      return Err(exception);
  }
});
```

- **One source of truth:** every screen reads the same drift row, so a like on the feed shows on Post Detail, in search results and on the profile without being told. A flow test checks this.
- **Exact rollback:** the repository restores the row's previous values, not "the opposite of the tap".
- **One at a time per key:** two quick taps on the same heart run in turn (`_oneAtATime`), so the second can't read the first's half-done state.
- **Undo is another write:** unsaving shows Undo, which simply saves again.

---

## 4. Refresh behind the cache

```dart
final cached = await _readCache();
if (cached.isNotEmpty) {
  unawaited(Future(refresh));
  return FeedState(posts: cached);
}
```

- `build` returns the cached state at once, and the refresh runs after it.
- `Future(…)` starts it on the next turn of the event loop, once Riverpod has put this build's state in place, so `refresh` has a state to update.
- A failed refresh keeps the posts and says so ("Couldn't refresh. Showing saved posts."); only with nothing cached does it become an error screen.

---

## 5. Patching state from drift, safely

Controllers `ref.listen` their stream providers and patch the state (a like changes one post). The patch goes through one guard:

```dart
void _update(FeedState Function(FeedState feed) change) {
  final feed = state.value;
  if (feed != null && !state.isLoading) state = AsyncData(change(feed));
}
```

- **No data yet:** nothing to patch; `build` will read the cache itself.
- **While reloading (`isLoading`):**
  - after Clear cache, the old build's streams emit the emptied tables before the reload finishes;
  - patching then would show "nothing", and end the loading state early;
  - a test records the feed's states during Clear cache and finds no empty one (§11.115).

---

## 6. Clear cache: one epoch, many screens

```
SettingsTools.clearCache()
  → CacheDao.clearServerData(me)      (saved posts, their authors, me and recent searches stay)
  → cacheEpoch.cleared()              (0 → 1)
  → every provider that ref.watch(cacheEpochProvider) rebuilds:
      feedController, postDetailController(id), notificationsController, searchHits(query), profileController(id)
  → each loads again; the old content stays under the loading state
```

ConnectHub-Flutter had a "cache cleared" stream that each Cubit subscribed to and reset itself from. Here it's one `ref.watch` line per screen.

---

## 7. Retry

- **No automatic retry:**
  - Riverpod 3 retries a failing provider up to 10 times by default, and reports loading meanwhile;
  - this app turns that off (`ProviderScope(retry: noAutomaticRetry)`, `app/retry_policy.dart`), because each screen offers "Try again";
  - a provider that should retry on its own would opt in with `@Riverpod(retry: …)`.
- **"Try again":**
  - `ref.invalidate(feedControllerProvider)` throws the failed state away and runs `build` again;
  - search's retry invalidates `searchHitsProvider(query)`.
- **Pull to refresh:** calls `refresh()`, which keeps what's on screen.
- **Load more's Retry:** the footer calls `loadMore()` again. `LoadMoreStatus` (idle / loading / failed / done) stops double requests.

---

## 8. What never happens

- **No effects in `build`:** `build` reads and returns; work starts from a method, `Future(refresh)`, or a listener.
- **No `BuildContext` in notifiers:** riverpod_lint's `avoid_build_context_in_providers`.
- **No silent failures:** every failed write or refresh ends in a message or an error state.
- **No timers outliving their provider:** `ref.debounce` cancels in `onDispose`, and tests fail on pending timers.
