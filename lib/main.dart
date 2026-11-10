import 'package:connect_hub_riverpod/app/connect_hub_app.dart';
import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:connect_hub_riverpod/core/storage/preferences_store.dart';
import 'package:connect_hub_riverpod/data/repository/settings_repository_impl.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Bindings must exist before the preferences' platform channel is used.
  WidgetsFlutterBinding.ensureInitialized();

  // Opened *before* runApp, so the settings can be read synchronously from
  // the first frame: a saved dark theme never flashes light (Rule 9).
  final preferences = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: SettingsRepositoryImpl.allowList,
    ),
  );

  runApp(
    // The ProviderScope holds the state of every provider in the app. It is
    // what get_it + injectable were in ConnectHub-Flutter (the object graph)
    // and what each BlocProvider was (the state's owner), in one widget. It
    // sits above `MaterialApp.router`, so every route can read providers.
    //
    // The one override in the app: the opened preferences, injected into
    // the graph (ConnectHub-Flutter used injectable's `@preResolve`).
    ProviderScope(
      retry: noAutomaticRetry,
      overrides: [
        preferencesStoreProvider.overrideWithValue(
          SharedPreferencesStore(preferences),
        ),
      ],
      child: const ConnectHubApp(),
    ),
  );
}
