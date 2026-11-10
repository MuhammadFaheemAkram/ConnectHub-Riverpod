import 'package:connect_hub_riverpod/core/network/api/fake_api_client.dart';
import 'package:connect_hub_riverpod/core/network/api/user_api_service.dart';
import 'package:connect_hub_riverpod/core/network/dto/post_dto.dart';
import 'package:connect_hub_riverpod/core/network/dto/user_dto.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';

/// [UserApiService] backed by the in-memory [FakeServer].
class FakeUserApiService implements UserApiService {
  const FakeUserApiService(this._client, this._server);

  final FakeApiClient _client;
  final FakeServer _server;

  static const _latency = Duration(milliseconds: 500);

  @override
  Future<UserDto> getUser(String userId) async {
    await _client.send(_latency);
    return _server.getUser(userId);
  }

  @override
  Future<List<PostDto>> getUserPosts(String userId) async {
    final viewerId = await _client.send(_latency);
    return _server.getUserPosts(viewerId, userId);
  }
}
