import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/app_routes.dart';
import 'package:material_ui/material_ui.dart';

/// The Profile tab: the signed-in user's own profile. A placeholder until
/// Phase 5, apart from the Settings gear.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => const SettingsRoute().push<void>(context),
          ),
        ],
      ),
      body: const EmptyStateView(
        icon: Icons.person_outline,
        title: 'Your profile is on its way',
        message: 'Your posts and saved posts arrive in Phase 5.',
      ),
    );
  }
}
