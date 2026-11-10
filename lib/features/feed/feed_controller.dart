import 'dart:async';

import 'package:connect_hub_riverpod/core/common/first_value.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/di/use_case_providers.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/features/feed/feed_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_controller.g.dart';

/// The cached feed window, live: drift's stream as a provider (Rule 5).
///
/// Auto-dispose: it lives while the Feed (through [FeedController]) listens,
/// and its drift query stops when nobody does.
@riverpod
Stream<List<Post>> feedPosts(Ref ref) => ref.watch(watchFeedUseCaseProvider)();

/// Drives the Feed: it shows the window cached in drift at once, refreshes
/// it from the server, pages it in, and likes and saves posts.
///
/// - An `AsyncNotifier`: the first load is asynchronous, and `AsyncValue`
///   gives the screen loading and error for free.
/// - Auto-dispose (the default): it lives while the Feed tab does. The tab
///   shell keeps the tab mounted while the user visits other tabs, so the
///   feed and its scroll position survive tab switches anyway.
/// - The intents are plain methods (`refresh`, `loadMore`, `toggleLike`):
///   the counterpart of ConnectHub-Flutter's Cubit methods, and of the
///   Android edition's MVI intents.
/// - Optimistic likes and saves happen in the repository; this only reports
///   a failure.
@riverpod
class FeedController extends _$FeedController {
  static const refreshFailedMessage = "Couldn't refresh. Showing saved posts.";
  static const likeFailedMessage =
      "Couldn't update the like. Please try again.";
  static const saveFailedMessage =
      "Couldn't update the save. Please try again.";

  @override
  Future<FeedState> build() async {
    // Clear cache bumps the epoch: watching it rebuilds the Feed, which then
    // loads again, as on a first launch.
    ref.watch(cacheEpochProvider);

    // Every change to the cached window (a like, a page, a refresh) updates
    // the posts in place. `listen`, not `watch`: watching would run this
    // build again on every change, and with it the first load's refresh.
    ref.listen(feedPostsProvider, (_, next) {
      if (next case AsyncData(value: final posts)) {
        _update((feed) => feed.copyWith(posts: posts));
      }
    });

    final cached = await _readCache();
    if (cached.isNotEmpty) {
      // Offline-first: the cached posts show at once, and the refresh runs
      // behind them. `Future(…)` starts it on the next turn of the event
      // loop, once Riverpod has put this build's state in place, so its
      // outcome has a state to update.
      unawaited(Future(refresh));
      return FeedState(posts: cached);
    }

    // Nothing cached: the screen waits (`AsyncLoading`) for the server. A
    // failure becomes `AsyncError`, and the screen offers "Try again"
    // (automatic retry is off app-wide: see `app/retry_policy.dart`).
    switch (await ref.read(refreshFeedUseCaseProvider)()) {
      case Ok(value: final hasMore):
        return FeedState(posts: await _readCache(), loadMore: _status(hasMore));
      case Err(:final exception):
        throw exception;
    }
  }

  /// Pull to refresh. Whatever is on screen stays while it runs.
  Future<void> refresh() async {
    if (!ref.mounted) return;
    final result = await ref.read(refreshFeedUseCaseProvider)();
    // The Feed may have been disposed while the request was in flight;
    // touching `state` now would throw (Rule 2).
    if (!ref.mounted) return;
    switch (result) {
      case Ok(value: final hasMore):
        // drift announces the new window asynchronously (conventions §11.3):
        // read it now, so the posts and the footer change together.
        final posts = await _readCache();
        if (!ref.mounted) return;
        _update(
          (feed) => feed.copyWith(posts: posts, loadMore: _status(hasMore)),
        );
      case Err(:final exception):
        final posts = state.value?.posts;
        if (posts == null) return;
        if (posts.isEmpty) {
          // Nothing to keep on screen: show the error, with "Try again".
          state = AsyncError(exception, StackTrace.current);
        } else {
          // The posts stay, and a SnackBar says why they may be stale.
          _update((feed) => feed.copyWith(message: refreshFailedMessage));
        }
    }
  }

  /// Loads the next page. The page calls it near the end of the list and
  /// from the footer's Retry. Ignored while a page is loading, and after the
  /// last one.
  Future<void> loadMore() async {
    final status = state.value?.loadMore;
    if (status == null ||
        status == LoadMoreStatus.loading ||
        status == LoadMoreStatus.done) {
      return;
    }
    _update((feed) => feed.copyWith(loadMore: LoadMoreStatus.loading));
    final result = await ref.read(loadMoreFeedUseCaseProvider)();
    if (!ref.mounted) return;
    final next = switch (result) {
      Ok(value: final hasMore) => _status(hasMore),
      Err() => LoadMoreStatus.failed,
    };
    _update((feed) => feed.copyWith(loadMore: next));
  }

  Future<void> toggleLike(Post post) async {
    final result = await ref.read(likePostUseCaseProvider)(
      post.id,
      liked: !post.isLiked,
    );
    if (!ref.mounted) return;
    if (result is Err<void>) {
      _update((feed) => feed.copyWith(message: likeFailedMessage));
    }
  }

  Future<void> toggleSave(Post post) async {
    final result = await ref.read(savePostUseCaseProvider)(
      post.id,
      saved: !post.isBookmarked,
    );
    if (!ref.mounted) return;
    if (result is Err<void>) {
      _update((feed) => feed.copyWith(message: saveFailedMessage));
    }
  }

  /// The page showed [FeedState.message]. Clearing it means the same
  /// message, failing again, is a change the page sees.
  void messageShown() => _update((feed) => feed.copyWith(message: null));

  /// What the cache holds now, read directly rather than from
  /// [feedPostsProvider], whose next event may still be on its way.
  Future<List<Post>> _readCache() =>
      ref.read(watchFeedUseCaseProvider)().firstValue;

  /// Changes the state, if it has a value, and not while rebuilding (after
  /// Clear cache): the emptied cache must not replace what's on screen with
  /// "nothing" before the reload.
  void _update(FeedState Function(FeedState feed) change) {
    final feed = state.value;
    if (feed != null && !state.isLoading) state = AsyncData(change(feed));
  }

  static LoadMoreStatus _status(bool hasMore) =>
      hasMore ? LoadMoreStatus.idle : LoadMoreStatus.done;
}
