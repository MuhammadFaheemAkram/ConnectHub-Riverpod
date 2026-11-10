import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub_riverpod/core/platform/platform_providers.dart';
import 'package:connect_hub_riverpod/domain/model/app_theme_mode.dart';
import 'package:connect_hub_riverpod/features/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Settings: appearance, wallpaper colors, the badge, storage, the developer
/// switch and About.
///
/// Two providers feed it. The preferences come from the *app-wide*
/// [settingsControllerProvider] that `MaterialApp` watches, so choosing Dark
/// here restyles the whole app at once. The actions (Clear cache, the
/// developer switch) come from the screen's own [settingsToolsProvider].
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(settingsToolsProvider.select((tools) => tools.message), (
      _,
      message,
    ) {
      if (message == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      ref.read(settingsToolsProvider.notifier).messageShown();
    });

    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    // The switch only where the platform has wallpaper colors (Android 12+).
    final hasWallpaperColors =
        ref.watch(platformColorSchemesProvider).value != null;
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton(),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
        children: [
          const _SectionHeader('Appearance'),
          _ThemeModePicker(selected: settings.themeMode),
          if (hasWallpaperColors)
            SwitchListTile(
              secondary: const Icon(Icons.wallpaper_outlined),
              title: const Text('Use wallpaper colors'),
              subtitle: const Text("Colors from your phone's wallpaper."),
              value: settings.useDynamicColor,
              onChanged: (enabled) =>
                  controller.setUseDynamicColor(enabled: enabled),
            ),
          const SizedBox(height: AppSpacing.medium),
          const _SectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Show unread badge'),
            subtitle: const Text('The count on the Notifications tab.'),
            value: settings.showUnreadBadge,
            onChanged: (enabled) =>
                controller.setShowUnreadBadge(enabled: enabled),
          ),
          const SizedBox(height: AppSpacing.small),
          const _SectionHeader('Storage'),
          const _ClearCacheTile(),
          const SizedBox(height: AppSpacing.small),
          const _SectionHeader('Developer'),
          const _NetworkFailureTile(),
          const SizedBox(height: AppSpacing.small),
          const _SectionHeader('About'),
          const _About(),
        ],
      ),
    );
  }
}

class _ThemeModePicker extends ConsumerWidget {
  const _ThemeModePicker({required this.selected});

  final AppThemeMode selected;

  static const _choices = [
    (AppThemeMode.system, 'System', Icons.brightness_auto_outlined),
    (AppThemeMode.light, 'Light', Icons.light_mode_outlined),
    (AppThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsControllerProvider.notifier);
    // Three segments share a phone's width. With large text, "System" would
    // break mid-word inside its segment, so the choices become a list.
    if (context.prefersStackedLayout) {
      return RadioGroup<AppThemeMode>(
        groupValue: selected,
        onChanged: (mode) {
          if (mode != null) settings.setThemeMode(mode);
        },
        child: Column(
          children: [
            for (final (mode, label, icon) in _choices)
              RadioListTile<AppThemeMode>(
                value: mode,
                title: Text(label),
                secondary: Icon(icon),
              ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: SegmentedButton<AppThemeMode>(
        segments: [
          for (final (mode, label, icon) in _choices)
            ButtonSegment(value: mode, icon: Icon(icon), label: Text(label)),
        ],
        selected: {selected},
        onSelectionChanged: (selection) =>
            settings.setThemeMode(selection.single),
      ),
    );
  }
}

class _ClearCacheTile extends ConsumerWidget {
  const _ClearCacheTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClearing = ref.watch(
      settingsToolsProvider.select((tools) => tools.isClearingCache),
    );
    return ListTile(
      leading: const Icon(Icons.cleaning_services_outlined),
      title: const Text('Clear cache'),
      subtitle: const Text(
        'Posts, profiles and notifications download again. Saved posts stay.',
      ),
      trailing: isClearing
          ? const ButtonProgress(semanticsLabel: 'Clearing the cache')
          : null,
      onTap: isClearing ? null : () => _confirm(context, ref),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final tools = ref.read(settingsToolsProvider.notifier);
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Clear cache?',
      message:
          'Cached posts, profiles, comments and notifications are deleted, '
          'and download again when you need them. Saved posts, recent '
          'searches and settings stay.',
      confirmLabel: 'Clear',
      isDestructive: true,
    );
    if (confirmed) await tools.clearCache();
  }
}

class _NetworkFailureTile extends ConsumerWidget {
  const _NetworkFailureTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failsRequests = ref.watch(
      settingsToolsProvider.select((tools) => tools.failsRequests),
    );
    return SwitchListTile(
      secondary: const Icon(Icons.wifi_off_outlined),
      title: const Text('Simulate network failure'),
      subtitle: const Text(
        'Every request fails, as if offline. Resets when the app restarts.',
      ),
      value: failsRequests,
      onChanged: (fail) => ref
          .read(settingsToolsProvider.notifier)
          .setNetworkFailure(fail: fail),
    );
  }
}

class _About extends ConsumerWidget {
  const _About();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider).value ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.hub_outlined),
          title: const Text('ConnectHub'),
          subtitle: Text('Version $version'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          child: Text(
            'The Riverpod edition: a feed, comments, search, notifications '
            'and profiles on a fake backend, built with Riverpod, drift and '
            'go_router to compare with the Bloc edition.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        AboutListTile(
          icon: const Icon(Icons.info_outline),
          applicationName: 'ConnectHub',
          applicationVersion: version,
          applicationLegalese: '© 2026 BitFuse · MIT License',
          child: const Text('Licenses'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.small,
        AppSpacing.medium,
        AppSpacing.xSmall,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
