import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/feed_repository.dart';

/// Appends the next page to the cached feed. Returns whether there are older
/// posts still to load.
class LoadMoreFeedUseCase {
  const LoadMoreFeedUseCase(this._feed);

  final FeedRepository _feed;

  Future<Result<bool>> call() => _feed.loadMore();
}
