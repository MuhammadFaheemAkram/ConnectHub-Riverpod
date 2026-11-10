import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// "No posts yet", still pullable to refresh.
class EmptyFeed extends StatelessWidget {
  const EmptyFeed({super.key, required this.onCreatePost});

  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    // RefreshIndicator needs something scrollable to pull, even when there is
    // nothing to scroll.
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: EmptyStateView(
              icon: Icons.dynamic_feed_outlined,
              title: 'No posts yet',
              message: 'Pull to refresh or share the first post.',
              action: FilledButton.tonal(
                onPressed: onCreatePost,
                child: const Text('New post'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
