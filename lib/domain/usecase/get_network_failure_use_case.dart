import 'package:connect_hub_riverpod/domain/repository/demo_tools_repository.dart';

/// Whether "Simulate network failure" is on.
class GetNetworkFailureUseCase {
  const GetNetworkFailureUseCase(this._tools);

  final DemoToolsRepository _tools;

  bool call() => _tools.failsRequests;
}
