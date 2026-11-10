import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'platform_providers.g.dart';

/// The wallpaper's colors, as a light and a dark scheme.
typedef PlatformColorSchemes = ({ColorScheme light, ColorScheme dark});

/// The platform's colors, or `null` where it has none (only Android 12+
/// does). Settings shows "Use wallpaper colors" only when this has a value.
///
/// `keepAlive`: asked once; the wallpaper doesn't change under a running
/// app often enough to watch. A platform with no plugin (tests, iOS) answers
/// with an exception, which means "no colors" too.
@Riverpod(keepAlive: true)
Future<PlatformColorSchemes?> platformColorSchemes(Ref ref) async {
  try {
    final palette = await DynamicColorPlugin.getCorePalette();
    if (palette == null) return null;
    return (
      light: palette.toColorScheme(),
      dark: palette.toColorScheme(brightness: Brightness.dark),
    );
  } on Exception {
    return null;
  }
}

/// "1.0.0 (1)": the version and build, for Settings → About.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}
