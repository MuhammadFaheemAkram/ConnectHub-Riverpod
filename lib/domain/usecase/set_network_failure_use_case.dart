import 'package:connect_hub_riverpod/domain/repository/demo_tools_repository.dart';

/// Turns "Simulate network failure" on or off.
class SetNetworkFailureUseCase {
  const SetNetworkFailureUseCase(this._tools);

  final DemoToolsRepository _tools;

  void call({required bool fail}) => _tools.setFailsRequests(fail: fail);
}
