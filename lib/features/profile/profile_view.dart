import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/app_routes.dart';
import 'package:connect_hub_riverpod/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/features/profile/profile_controller.dart';
import 'package:connect_hub_riverpod/features/profile/profile_state.dart';
import 'package:connect_hub_riverpod/features/profile/widgets/profile_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// A profile: the header (picture, name, bio, counts), then the posts.
///
/// [isMine] decides the extras. My profile is a tab root with a Settings
/// gear and **Posts | Saved**; anyone else's is pushed over the tabs, with a
/// Back button, and shows their posts.
class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key, required this.userId, required this.isMine});

  final String userId;
  final bool isMine;

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  /// Posts (false) or Saved (true): UI state, so it lives here, not in a
  /// provider.
  var _showSaved = false;

  ProfileControllerProvider get _provider =>
      profileControllerProvider(widget.userId);

  @override
  Widget build(BuildContext context) {
    ref.listen(_provider.select((profile) => profile.value?.message), (
      _,
      message,
    ) {
      if (message == null) return;
      _snack(context, message);
      ref.read(_provider.notifier).messageShown();
    });
    // Saved exists on my own profile only (isMine never changes for a given
    // page, so this listen is always there, or never).
    if (widget.isMine) {
      ref.listen(
        savedPostsControllerProvider.select(
          (saved) => (saved.value?.message, saved.value?.undoable),
        ),
        (_, next) {
          final (message, undoable) = next;
          if (message == null) return;
          final saved = ref.read(savedPostsControllerProvider.notifier);
          _snack(
            context,
            message,
            action: undoable == null
                ? null
                : SnackBarAction(
                    label: 'Undo',
                    onPressed: () => saved.undo(undoable),
                  ),
          );
          saved.messageShown();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.isMine ? null : const BackToFeedButton(),
        title: const Text('Profile'),
        actions: [
          if (widget.isMine)
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => const SettingsRoute().push<void>(context),
            ),
        ],
      ),
      body: switch (ref.watch(_provider)) {
        AsyncValue(value: final profile?) => RefreshIndicator(
          onRefresh: () => _refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.large),
            children: [
              ProfileHeader(
                user: profile.user,
                postCount: profile.posts.length,
              ),
              const SizedBox(height: AppSpacing.small),
              if (widget.isMine)
                _PostsOrSaved(
                  showSaved: _showSaved,
                  onChanged: (showSaved) =>
                      setState(() => _showSaved = showSaved),
                )
              else
                const Divider(height: AppSpacing.large),
              ...(_showSaved && widget.isMine
                  ? _savedPosts()
                  : _posts(profile)),
            ],
          ),
        ),
        AsyncValue(isLoading: true) => const LoadingView(
          message: 'Loading profile…',
        ),
        AsyncError(error: NotFoundException()) => const EmptyStateView(
          icon: Icons.person_off_outlined,
          title: "This profile isn't available.",
        ),
        AsyncError(:final error) => ErrorView(
          message: error is AppException
              ? error.message
              : const UnknownException().message,
          onRetry: () => ref.invalidate(_provider),
        ),
        _ => const LoadingView(message: 'Loading profile…'),
      },
    );
  }

  Future<void> _refresh() async {
    final profile = ref.read(_provider.notifier).refresh();
    if (_showSaved) {
      await ref.read(savedPostsControllerProvider.notifier).refresh();
    }
    await profile;
  }

  List<Widget> _posts(ProfileState profile) {
    if (profile.posts.isEmpty) {
      return [
        _QuietText(widget.isMine ? "You haven't posted yet." : 'No posts yet.'),
      ];
    }
    final controller = ref.read(_provider.notifier);
    return [
      for (final post in profile.posts)
        _card(
          post,
          onLike: () => controller.toggleLike(post),
          onSave: () => controller.toggleSave(post),
        ),
    ];
  }

  List<Widget> _savedPosts() {
    final saved = ref.watch(savedPostsControllerProvider);
    final posts = saved.value?.posts;
    if (posts == null) {
      return const [
        Padding(
          padding: EdgeInsets.all(AppSpacing.large),
          child: Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading saved'),
          ),
        ),
      ];
    }
    if (posts.isEmpty) {
      return const [
        _QuietText('Nothing saved yet. Tap the bookmark on a post to save it.'),
      ];
    }
    final controller = ref.read(savedPostsControllerProvider.notifier);
    return [
      for (final post in posts)
        _card(
          post,
          onAuthorTap: () => openProfile(context, post.author.id),
          onLike: () => ref.read(_provider.notifier).toggleLike(post),
          onSave: () => controller.unsave(post),
        ),
    ];
  }

  Widget _card(
    Post post, {
    VoidCallback? onAuthorTap,
    required VoidCallback onLike,
    required VoidCallback onSave,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.medium,
      0,
      AppSpacing.medium,
      AppSpacing.small,
    ),
    child: PostCard(
      key: ValueKey(post.id),
      post: post,
      onTap: () => PostDetailRoute(postId: post.id).push<void>(context),
      onComment: () => PostDetailRoute(postId: post.id).push<void>(context),
      // On their own profile, the author is this page already.
      onAuthorTap: onAuthorTap,
      onLike: onLike,
      onSave: onSave,
    ),
  );

  static void _snack(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }
}

/// Posts | Saved, on my own profile.
class _PostsOrSaved extends StatelessWidget {
  const _PostsOrSaved({required this.showSaved, required this.onChanged});

  final bool showSaved;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: showSaved ? 1 : 0,
      child: TabBar(
        onTap: (index) => onChanged(index == 1),
        tabs: const [
          Tab(text: 'Posts'),
          Tab(text: 'Saved'),
        ],
      ),
    );
  }
}

class _QuietText extends StatelessWidget {
  const _QuietText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
