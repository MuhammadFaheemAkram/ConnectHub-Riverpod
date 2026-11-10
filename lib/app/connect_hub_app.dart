import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget: themes and the router.
///
/// A `ConsumerWidget` is a `StatelessWidget` that also receives a `ref`. It
/// *watches* the router provider, so it rebuilds if the router is ever
/// replaced (a test override, say). Compare ConnectHub-Flutter's
/// `StatefulWidget`, which had to create, own and dispose the router, the
/// session's Bloc and a listenable: here the providers own them all, and
/// the widget only reads.
class ConnectHubApp extends ConsumerWidget {
  const ConnectHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ConnectHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // No `themeMode` yet: the default follows the device's light or dark
      // setting, until Settings (Phase 5) adds a choice.
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
