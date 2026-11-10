import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_state.freezed.dart';

/// Where loading the next page stands. The list's footer shows it.
enum LoadMoreStatus {
  /// Ready to load the next page when the user nears the end.
  idle,
  loading,

  /// The last attempt failed; the footer offers Retry.
  failed,

  /// The window reaches the oldest post: "You're all caught up".
  done,
}

/// What the Feed shows once it has something to show.
///
/// Loading and "couldn't load" are not in here: they are the `AsyncValue`
/// around it (`AsyncLoading`, `AsyncError`). ConnectHub-Flutter's
/// `FeedState` had four cases of its own (loading, empty, error, loaded);
/// Riverpod's `AsyncValue` already models three of them, so this is just
/// the data, and "empty" is `posts.isEmpty`.
@freezed
abstract class FeedState with _$FeedState {
  const factory FeedState({
    /// The cached window, newest first.
    required List<Post> posts,
    @Default(LoadMoreStatus.idle) LoadMoreStatus loadMore,

    /// A one-off SnackBar. The page shows it from `ref.listen` and then
    /// calls `messageShown()`, so it shows once (Correctness Rule 3).
    String? message,
  }) = _FeedState;
}
