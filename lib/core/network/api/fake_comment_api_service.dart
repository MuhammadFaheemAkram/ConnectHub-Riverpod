import 'package:connect_hub_riverpod/core/network/api/comment_api_service.dart';
import 'package:connect_hub_riverpod/core/network/api/fake_api_client.dart';
import 'package:connect_hub_riverpod/core/network/dto/comment_dto.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';

/// [CommentApiService] backed by the in-memory [FakeServer].
class FakeCommentApiService implements CommentApiService {
  const FakeCommentApiService(this._client, this._server);

  final FakeApiClient _client;
  final FakeServer _server;

  static const _readLatency = Duration(milliseconds: 500);
  static const _sendLatency = Duration(milliseconds: 450);
  static const _writeLatency = Duration(milliseconds: 350);

  @override
  Future<List<CommentDto>> getComments(String postId) async {
    final userId = await _client.send(_readLatency);
    return _server.getComments(userId, postId);
  }

  @override
  Future<CommentDto> addComment(String postId, String text) async {
    final userId = await _client.send(_sendLatency);
    return _server.addComment(userId, postId, text);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final userId = await _client.send(_writeLatency);
    return _server.deleteComment(userId, commentId);
  }

  @override
  Future<CommentDto> setLiked(String commentId, {required bool liked}) async {
    final userId = await _client.send(_writeLatency);
    return _server.setCommentLiked(userId, commentId, liked: liked);
  }
}
