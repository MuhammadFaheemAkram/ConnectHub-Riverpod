import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Nothing typed: the recent searches, or a prompt when there are none.
class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.searches,
    required this.onSelected,
    required this.onClear,
  });

  final List<String> searches;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const EmptyStateView(
        icon: Icons.travel_explore,
        title: 'Search ConnectHub',
        message: 'Find people and posts by name or keyword.',
      );
    }
    final theme = Theme.of(context);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.xSmall,
            AppSpacing.xSmall,
            0,
          ),
          // A Wrap, not a Row: at large text the title and the button no
          // longer fit side by side, and the button moves under the title
          // (found by the accessibility tour at 200 %).
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Recent searches',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear history'),
              ),
            ],
          ),
        ),
        for (final query in searches)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            onTap: () => onSelected(query),
          ),
      ],
    );
  }
}
