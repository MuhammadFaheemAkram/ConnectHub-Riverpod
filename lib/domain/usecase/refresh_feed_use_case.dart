import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/feed_repository.dart';

/// Replaces the cached feed with the newest page. Returns whether there are
/// older posts to load.
class RefreshFeedUseCase {
  const RefreshFeedUseCase(this._feed);

  final FeedRepository _feed;

  Future<Result<bool>> call() => _feed.refresh();
}
