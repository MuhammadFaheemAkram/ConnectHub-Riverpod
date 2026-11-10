import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// The Feed tab. A placeholder until Phase 2 builds the feed with an
/// `AsyncNotifier`.
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConnectHub')),
      body: const EmptyStateView(
        icon: Icons.dynamic_feed_outlined,
        title: 'Your feed is on its way',
        message: 'Posts, likes and saves arrive in Phase 2.',
      ),
    );
  }
}
