import 'package:connect_hub_riverpod/core/common/compact_count.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:material_ui/material_ui.dart';

/// The picture, name, bio and the three counts.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user, required this.postCount});

  final User user;
  final int postCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.medium,
        0,
      ),
      child: Column(
        children: [
          UserAvatar(name: user.name, url: user.avatarUrl, size: 96),
          const SizedBox(height: AppSpacing.small),
          Text(
            user.name,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxSmall),
            Text(
              user.bio,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.medium),
          // A Wrap, not a Row of thirds: with large text, the counts move
          // onto a second row instead of breaking "Followers" mid-word.
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              _Count(label: 'Followers', count: user.followersCount),
              _Count(label: 'Following', count: user.followingCount),
              _Count(label: 'Posts', count: postCount),
            ],
          ),
        ],
      ),
    );
  }
}

/// "4.8K" over "Followers", read out as one phrase.
class _Count extends StatelessWidget {
  const _Count({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = compactCount(count);
    return ConstrainedBox(
      // About a third of a phone's width, so the three sit evenly in a row.
      constraints: const BoxConstraints(minWidth: 96),
      child: Semantics(
        // Its own node, so each count is read (and focused) on its own.
        container: true,
        label: '$value $label',
        excludeSemantics: true,
        child: Column(
          children: [
            Text(value, style: theme.textTheme.titleMedium),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
