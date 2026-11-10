import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/repository/feed_repository.dart';

/// The cached feed as a stream: the current window, then every change.
class WatchFeedUseCase {
  const WatchFeedUseCase(this._feed);

  final FeedRepository _feed;

  Stream<List<Post>> call() => _feed.watchFeed();
}
