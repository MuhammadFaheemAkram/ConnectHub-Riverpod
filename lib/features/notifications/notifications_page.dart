import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// The Notifications tab. A placeholder until Phase 4.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const EmptyStateView(
        icon: Icons.notifications_none,
        title: 'No notifications yet',
        message: 'Likes, comments, follows and mentions arrive in Phase 4.',
      ),
    );
  }
}
