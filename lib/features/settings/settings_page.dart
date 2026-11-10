import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Settings, pushed above the tabs. A placeholder until Phase 5.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const EmptyStateView(
        icon: Icons.settings_outlined,
        title: 'Settings are on their way',
        message:
            'Appearance, wallpaper colors, the unread badge and the '
            'developer tools arrive in Phase 5.',
      ),
    );
  }
}
