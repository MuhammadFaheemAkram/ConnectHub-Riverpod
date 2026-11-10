import 'package:connect_hub_riverpod/core/network/api/developer_tools_service.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';

/// [DeveloperToolsService] for the fake backend: the [NetworkSimulator]'s
/// failure switch, kept in memory, so it resets when the app restarts.
class FakeDeveloperToolsService implements DeveloperToolsService {
  const FakeDeveloperToolsService(this._network);

  final NetworkSimulator _network;

  @override
  bool get failsRequests => _network.failRequests;

  @override
  set failsRequests(bool value) => _network.failRequests = value;
}
