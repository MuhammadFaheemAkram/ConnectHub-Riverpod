import 'package:connect_hub_riverpod/core/network/api/developer_tools_service.dart';
import 'package:connect_hub_riverpod/domain/repository/demo_tools_repository.dart';

/// Settings → Developer, over the fake backend's [DeveloperToolsService].
class DemoToolsRepositoryImpl implements DemoToolsRepository {
  DemoToolsRepositoryImpl(this._tools);

  final DeveloperToolsService _tools;

  @override
  bool get failsRequests => _tools.failsRequests;

  @override
  void setFailsRequests({required bool fail}) => _tools.failsRequests = fail;
}
