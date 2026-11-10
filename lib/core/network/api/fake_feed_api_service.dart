import 'package:connect_hub_riverpod/core/network/api/fake_api_client.dart';
import 'package:connect_hub_riverpod/core/network/api/feed_api_service.dart';
import 'package:connect_hub_riverpod/core/network/dto/post_dto.dart';
import 'package:connect_hub_riverpod/core/network/dto/post_page_dto.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';

/// [FeedApiService] backed by the in-memory [FakeServer].
class FakeFeedApiService implements FeedApiService {
  const FakeFeedApiService(this._client, this._server);

  final FakeApiClient _client;
  final FakeServer _server;

  static const _readLatency = Duration(milliseconds: 700);
  static const _writeLatency = Duration(milliseconds: 350);

  @override
  Future<PostPageDto> getFeed({String? cursor, int limit = 6}) async {
    final userId = await _client.send(_readLatency);
    return _server.getFeed(userId, cursor: cursor, limit: limit);
  }

  @override
  Future<PostDto> setLiked(String postId, {required bool liked}) async {
    final userId = await _client.send(_writeLatency);
    return _server.setLiked(userId, postId, liked: liked);
  }

  @override
  Future<PostDto> setBookmarked(
    String postId, {
    required bool bookmarked,
  }) async {
    final userId = await _client.send(_writeLatency);
    return _server.setBookmarked(userId, postId, bookmarked: bookmarked);
  }
}
