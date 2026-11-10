import 'package:connect_hub_riverpod/app/theme_mode_mapper.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/app_router.dart';
import 'package:connect_hub_riverpod/core/platform/platform_providers.dart';
import 'package:connect_hub_riverpod/features/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget: themes and the router.
///
/// A `ConsumerWidget` is a `StatelessWidget` that also receives a `ref`. It
/// *watches* the router provider, and two slices of the settings (`select`):
/// only a change of theme or of "Use wallpaper colors" rebuilds the app,
/// not the badge switch. Compare ConnectHub-Flutter's `StatefulWidget`,
/// which had to create, own and dispose the router, the session's Bloc and a
/// listenable: here the providers own them all, and the widget only reads.
///
/// The settings are read synchronously (see `SettingsController`), so the
/// first frame already has the saved theme.
class ConnectHubApp extends ConsumerWidget {
  const ConnectHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      settingsControllerProvider.select((settings) => settings.themeMode),
    );
    final useDynamicColor = ref.watch(
      settingsControllerProvider.select((settings) => settings.useDynamicColor),
    );
    // `null` until the platform answers, and where it has no colors: the
    // seed's theme meanwhile.
    final wallpaper = useDynamicColor
        ? ref.watch(platformColorSchemesProvider).value
        : null;
    return MaterialApp.router(
      title: 'ConnectHub',
      debugShowCheckedModeBanner: false,
      theme: wallpaper == null
          ? AppTheme.light()
          : AppTheme.fromScheme(wallpaper.light),
      darkTheme: wallpaper == null
          ? AppTheme.dark()
          : AppTheme.fromScheme(wallpaper.dark),
      themeMode: themeMode.toThemeMode(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
