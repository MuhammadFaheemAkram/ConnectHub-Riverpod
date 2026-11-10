import 'package:connect_hub_riverpod/core/common/compact_count.dart';
import 'package:connect_hub_riverpod/core/design_system/theme/app_colors.dart';
import 'package:connect_hub_riverpod/core/design_system/theme/app_icon_size.dart';
import 'package:connect_hub_riverpod/core/design_system/theme/app_spacing.dart';
import 'package:connect_hub_riverpod/core/design_system/widgets/relative_time_text.dart';
import 'package:connect_hub_riverpod/core/design_system/widgets/user_avatar.dart';
import 'package:connect_hub_riverpod/domain/model/comment.dart';
import 'package:material_ui/material_ui.dart';

/// One comment: the author's picture and name ("You" for the signed-in
/// user's own), the time, the text, and a like button with its count.
///
/// [onDelete] adds a ⋮ menu with "Delete". Screens pass it only for the
/// user's own comments; confirming is up to them.
class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.onAuthorTap,
    this.onLike,
    this.onDelete,
  });

  final Comment comment;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onLike;
  final VoidCallback? onDelete;

  /// The picture is 36 px, but tapping it needs a 48 × 48 target (the
  /// minimum for touch). The extra 6 px around it come out of the padding,
  /// so the picture and the text stay where they were.
  static const _avatarSize = 36.0;
  static const _tapTarget = 48.0;
  static const _inset = (_tapTarget - _avatarSize) / 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = comment.author;
    final onDelete = this.onDelete;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium - _inset,
        AppSpacing.xSmall - _inset,
        AppSpacing.xxSmall,
        AppSpacing.xSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            dimension: _tapTarget,
            child: InkWell(
              onTap: onAuthorTap,
              customBorder: const CircleBorder(),
              child: Center(
                child: UserAvatar(
                  name: author.name,
                  url: author.avatarUrl,
                  size: _avatarSize,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.small - _inset),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: _inset),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.isMine ? 'You' : author.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xSmall),
                    RelativeTimeText(
                      comment.createdAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxSmall),
                Text(comment.text, style: theme.textTheme.bodyMedium),
                _LikeButton(comment: comment, onPressed: onLike),
              ],
            ),
          ),
          if (onDelete != null)
            PopupMenuButton<void>(
              tooltip: 'Comment options',
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem<void>(
                  onTap: onDelete,
                  child: const Text('Delete'),
                ),
              ],
            )
          else
            const SizedBox(width: AppSpacing.small),
        ],
      ),
    );
  }
}

/// "♥ 4" under the comment, tappable as one button ("Like comment",
/// "Unlike comment").
class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.comment, required this.onPressed});

  final Comment comment;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final liked = comment.isLiked;
    return Tooltip(
      message: liked ? 'Unlike comment' : 'Like comment',
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xSmall),
        ),
        onPressed: onPressed,
        icon: Icon(
          liked ? Icons.favorite : Icons.favorite_border,
          size: AppIconSize.small,
          color: liked ? context.appColors.like : null,
        ),
        label: Text(compactCount(comment.likeCount)),
      ),
    );
  }
}
