import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';

/// The posts a search found, live from the cache, in the server's order.
class WatchSearchPostsUseCase {
  const WatchSearchPostsUseCase(this._search);

  final SearchRepository _search;

  Stream<List<Post>> call(List<String> ids) => _search.watchPosts(ids);
}
