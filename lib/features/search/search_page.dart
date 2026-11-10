import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// The Search tab. A placeholder until Phase 4 adds debounced search.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const EmptyStateView(
        icon: Icons.search,
        title: 'Search ConnectHub',
        message: 'Finding people and posts arrives in Phase 4.',
      ),
    );
  }
}
