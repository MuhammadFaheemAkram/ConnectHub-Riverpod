# API simulation

ConnectHub runs with **no server**. A `FakeServer` lives in memory and owns the data and its rules. The app reaches it only through API service interfaces, exactly as it would reach a real backend. Swapping in a real one means writing HTTP implementations of those interfaces and pointing their providers at them; repositories, notifiers and screens stay as they are.

```
Repository ─▶ guardApiCall ─▶ FeedApiService (interface)          ← feedApiServiceProvider
                                  │ FakeFeedApiService
                                  ▼
                          FakeApiClient.send(latency)
                             ├─ NetworkSimulator: waits the latency × factor, fails if "offline"
                             └─ returns the signed-in user's id ('u_demo')
                                  ▼
                          FakeServer.getFeed(userId, cursor, limit) ─▶ PostPageDto
```

- **Everything is a provider** (`core/network/network_providers.dart`, the only way into `core/network/`): the asset bundle, the simulator, the server, the client and the six services. Tests override the simulator with `NetworkSimulator(latencyFactor: 0)`.
- **`guardApiCall`** (`data/repository/api_guard.dart`) turns the outcome into a `Result`:
  - an `AppException` (`NetworkException`, `NotFoundException`, …) becomes an `Err` with its message;
  - any other `Exception` (a refused request's `FormatException`, say) is logged and becomes `UnknownException`;
  - `Error`s aren't caught, so tests still see programming mistakes.
- **No sign-in:** the demo user (`u_demo`) is always signed in. ConnectHub-Flutter has accounts, tokens and a 401 flow; this edition left them out (they're out of scope in both native editions too).

---

## Services

| Service | Calls | Latency |
|---|---|---|
| `FeedApiService` | `getFeed(cursor, limit)`, `getPost`, `getBookmarks` · `createPost` · `setLiked`, `setBookmarked` | 700 ms reads · 600 ms create · 350 ms writes |
| `CommentApiService` | `getComments` · `addComment` · `deleteComment`, `setCommentLiked` | 500 ms · 450 ms · 350 ms |
| `SearchApiService` | `search(query)` | 400 ms |
| `NotificationApiService` | `getNotifications` · `markRead`, `markAllRead` | 500 ms · 350 ms |
| `UserApiService` | `getUser`, `getUserPosts` | 500 ms |
| `DeveloperToolsService` | `failsRequests` (Settings → Developer) | — |

The latencies are multiplied by `NetworkSimulator.latencyFactor`: 1.0 in the app, 0 in tests.

---

## Seed data

The server seeds itself on first use from [`assets/json/`](../assets/json/) (ConnectHub-Flutter's seed, without chat and accounts), then keeps everything in memory.

| File | Contents |
|---|---|
| `auth_user.json` | the demo user, `u_demo` ("Demo User"): 128 followers, 87 following |
| `feed_posts.json` | 17 posts by six people, with likes and images; `p16` and `p17` are the demo user's |
| `comments.json` | 13 comments; `c12` and `c13` are on the demo user's posts |
| `notifications.json` | 8 notifications (3 unread): likes, comments, follows, mentions, each linking to a post or a user |

**Additions over ConnectHub-Flutter's server:**
- **Comment likes** (new in this edition): per user and idempotent, like post likes. The seed's counts are in `FakeServer.seedCommentLikes`: c1 4, c2 12, c3 1, c5 3, c7 9, c12 2.
- **Fresh dates:** every seed date is shifted by the same amount at launch, so the newest record (notification n1) is five minutes old and the app always looks recent. The gaps between records are kept.
- **Counts come from the server:** `likeCount` starts from the seed and moves with likes. `commentCount` is always counted from the comments themselves.

---

## Server rules

- **Feed pages:**
  - newest first, 6 per page, each ending with an opaque cursor;
  - the cursor marks a position ("older than this post"), not an offset, so a post created meanwhile can't shift a page;
  - the 17 posts arrive as 6 / 6 / 5.
- **Likes and saves** (bookmarks underneath) are per user and idempotent: liking twice counts once. Saved posts come back the most recently saved first.
- **Posts and comments:**
  - written as the demo user, checked against the client's rules (a post: 1–280 characters and an optional `http(s)` image URL; a comment: 1–500), and stored trimmed;
  - a request that breaks them is refused like a 400 (a `FormatException`; the client validates first, so the app never sends one);
  - only a comment's author may delete it; anyone else gets a 404, so a stranger can't confirm the comment exists.
- **Search:** case-insensitive "contains". People by name or bio (never yourself), the most followed first; posts by content or author name, newest first.
- **Users:** `getUser` answers a 404 for an unknown id. `getUserPosts` lists one author's posts, newest first.
- **Notifications:** newest first. The read state is the server's, so a refresh never resets it; marking someone else's notification read is a 404.

---

## Developer switch (Settings → Developer)

| Switch | Effect | Lifetime |
|---|---|---|
| **Simulate network failure** | every request fails with "Something went wrong with your connection." after its latency, as if offline. Cached data stays on screen; optimistic writes roll back | in memory: resets when the app restarts |

---

## Errors

| Exception | Message | When |
|---|---|---|
| `NetworkException` | Something went wrong with your connection. Please try again. | the network is "offline" |
| `NotFoundException` | We couldn't find what you were looking for. | an unknown post or user, or someone else's comment or notification |
| `DataFormatException` | We received an unexpected response. Please try again. | a malformed response |
| `UnknownException` | Something went wrong. Please try again. | anything else (logged by `guardApiCall`) |

---

## What a restart resets

- **The server** lives in memory, so every launch starts from the seed: new posts, comments, likes, saves and read states are gone.
- **The client's cache** (drift) keeps what it had until the next refresh mirrors the fresh server.
- **Settings → Clear cache** empties the cache on purpose. It keeps saved posts (with their authors), the demo user and recent searches; everything else downloads again.
