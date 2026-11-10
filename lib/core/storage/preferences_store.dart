import 'package:shared_preferences/shared_preferences.dart';

/// Small, non-secret values the device owns: the settings.
///
/// An interface of four methods instead of `SharedPreferencesWithCache`
/// itself, so tests can use a plain map, synchronously, with no platform
/// channel.
abstract interface class PreferencesStore {
  String? getString(String key);

  bool? getBool(String key);

  Future<void> setString(String key, String value);

  Future<void> setBool(String key, {required bool value});
}

/// [PreferencesStore] over `SharedPreferencesWithCache`, created once before
/// `runApp` (see `main.dart`): reads are synchronous from then on, and
/// writes update the cache at once and the disk asynchronously.
class SharedPreferencesStore implements PreferencesStore {
  const SharedPreferencesStore(this._preferences);

  final SharedPreferencesWithCache _preferences;

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  bool? getBool(String key) => _preferences.getBool(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> setBool(String key, {required bool value}) =>
      _preferences.setBool(key, value);
}
