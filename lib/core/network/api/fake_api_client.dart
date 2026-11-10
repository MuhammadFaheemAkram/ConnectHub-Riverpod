import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';

/// The fake counterpart of an HTTP client with an auth interceptor.
///
/// Every fake call starts with [send]: it crosses the simulated network
/// (latency, simulated failures) and returns the user the request is made as.
/// A real client would attach the session's token here; in this edition the
/// demo user is always signed in, so the server names them.
class FakeApiClient {
  const FakeApiClient(this._network, this._server);

  final NetworkSimulator _network;
  final FakeServer _server;

  /// Starts a request that takes [latency] on the wire, and returns the id
  /// of the signed-in user. Throws `NetworkException` if the simulated
  /// network fails.
  Future<String> send(Duration latency) async {
    await _network.run(latency);
    return _server.signedInUserId();
  }
}
