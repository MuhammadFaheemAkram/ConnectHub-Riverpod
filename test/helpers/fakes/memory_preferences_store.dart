import 'package:connect_hub_riverpod/core/storage/preferences_store.dart';

/// A [PreferencesStore] in a map: synchronous, no platform channel. Pass
/// [values] to start with saved settings ("from the last launch").
class MemoryPreferencesStore implements PreferencesStore {
  MemoryPreferencesStore([Map<String, Object>? values]) : values = {...?values};

  final Map<String, Object> values;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> setBool(String key, {required bool value}) async =>
      values[key] = value;
}
