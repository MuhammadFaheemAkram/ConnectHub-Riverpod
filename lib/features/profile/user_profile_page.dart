import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/back_to_feed_button.dart';
import 'package:material_ui/material_ui.dart';

/// Someone's profile, opened from search results and notifications. A
/// placeholder until Phase 5 builds profiles.
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton(),
        title: const Text('Profile'),
      ),
      body: const EmptyStateView(
        icon: Icons.person_outline,
        title: 'Profiles are on their way',
        message: "People's profiles and their posts arrive in Phase 5.",
      ),
    );
  }
}
