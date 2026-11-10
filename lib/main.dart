import 'package:connect_hub_riverpod/app/connect_hub_app.dart';
import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(
    // The ProviderScope holds the state of every provider in the app. It is
    // what get_it + injectable were in ConnectHub-Flutter (the object graph)
    // and what each BlocProvider was (the state's owner), in one widget. It
    // sits above `MaterialApp.router`, so every route can read providers.
    const ProviderScope(retry: noAutomaticRetry, child: ConnectHubApp()),
  );
}
