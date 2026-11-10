/// Settings → Developer: a switch for trying offline and error states.
abstract interface class DemoToolsRepository {
  /// Whether every request fails, as if offline. Kept in memory: it resets
  /// when the app restarts.
  bool get failsRequests;

  void setFailsRequests({required bool fail});
}
