/// The switch behind Settings → Developer → "Simulate network failure".
///
/// Behind an interface in `core/network/`, like the API services, so
/// nothing outside this folder touches the fake backend.
abstract interface class DeveloperToolsService {
  /// Whether every request fails, as if offline.
  bool get failsRequests;

  set failsRequests(bool value);
}
