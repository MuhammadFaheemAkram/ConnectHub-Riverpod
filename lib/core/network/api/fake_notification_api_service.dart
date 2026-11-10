import 'package:connect_hub_riverpod/core/network/api/fake_api_client.dart';
import 'package:connect_hub_riverpod/core/network/api/notification_api_service.dart';
import 'package:connect_hub_riverpod/core/network/dto/notification_dto.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';

/// [NotificationApiService] backed by the in-memory [FakeServer].
class FakeNotificationApiService implements NotificationApiService {
  const FakeNotificationApiService(this._client, this._server);

  final FakeApiClient _client;
  final FakeServer _server;

  static const _readLatency = Duration(milliseconds: 500);
  static const _writeLatency = Duration(milliseconds: 350);

  @override
  Future<List<NotificationDto>> getNotifications() async {
    final userId = await _client.send(_readLatency);
    return _server.getNotifications(userId);
  }

  @override
  Future<void> markRead(String notificationId) async {
    final userId = await _client.send(_writeLatency);
    return _server.markNotificationRead(userId, notificationId);
  }

  @override
  Future<void> markAllRead() async {
    final userId = await _client.send(_writeLatency);
    return _server.markAllNotificationsRead(userId);
  }
}
