import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/core/database/daos/bookmarks_dao.dart';
import 'package:connect_hub_riverpod/core/network/api/feed_api_service.dart';
import 'package:connect_hub_riverpod/data/mapper/post_mappers.dart';
import 'package:connect_hub_riverpod/data/repository/api_guard.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/repository/saved_posts_repository.dart';

/// Saved posts are the server's bookmarks; the cache is what makes them work
/// offline. This repository only lists them: saving and unsaving go through
/// `PostRepository.setBookmarked`, so a change anywhere shows here at once.
class SavedPostsRepositoryImpl implements SavedPostsRepository {
  SavedPostsRepositoryImpl(this._api, this._bookmarks);

  final FeedApiService _api;
  final BookmarksDao _bookmarks;

  @override
  Stream<List<Post>> watchSavedPosts() => _bookmarks.watchBookmarks().map(
    (entries) => [for (final entry in entries) entry.toDomain()],
  );

  @override
  Future<Result<void>> refreshSavedPosts() async {
    final result = await guardApiCall(_api.getBookmarks);
    switch (result) {
      case Ok(value: final posts):
        await _bookmarks.replaceBookmarks([
          for (final post in posts) post.toCached(),
        ]);
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }
}
