import 'package:connect_hub_riverpod/core/common/compact_count.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/model/search_results.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:material_ui/material_ui.dart';

/// The results in two sections, People then Posts; a section with nothing
/// in it (or hidden by the scope) is left out.
class SearchResultList extends StatelessWidget {
  const SearchResultList({
    super.key,
    required this.results,
    required this.onOpenPerson,
    required this.onOpenPost,
    required this.onOpenAuthor,
    required this.onLike,
    required this.onSave,
  });

  final SearchResults results;
  final ValueChanged<User> onOpenPerson;
  final ValueChanged<Post> onOpenPost;
  final ValueChanged<Post> onOpenAuthor;
  final ValueChanged<Post> onLike;
  final ValueChanged<Post> onSave;

  @override
  Widget build(BuildContext context) {
    final people = results.users;
    final posts = results.posts;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppSpacing.large),
      children: [
        if (people.isNotEmpty) ...[
          const _SectionTitle('People'),
          for (final user in people)
            _PersonTile(user: user, onTap: () => onOpenPerson(user)),
        ],
        if (posts.isNotEmpty) ...[
          const _SectionTitle('Posts'),
          for (final post in posts)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                0,
                AppSpacing.medium,
                AppSpacing.small,
              ),
              child: PostCard(
                key: ValueKey(post.id),
                post: post,
                onTap: () => onOpenPost(post),
                onAuthorTap: () => onOpenAuthor(post),
                onComment: () => onOpenPost(post),
                onLike: () => onLike(post),
                onSave: () => onSave(post),
              ),
            ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.xSmall,
      ),
      child: Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

/// A person in the results: picture, name, bio and follower count.
class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final followers = compactCount(user.followersCount);
    return ListTile(
      // The name is right next to it, so the picture stays silent.
      leading: ExcludeSemantics(
        child: UserAvatar(name: user.name, url: user.avatarUrl),
      ),
      title: Text(user.name),
      subtitle: Text(
        user.bio.isEmpty ? '$followers followers' : user.bio,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
