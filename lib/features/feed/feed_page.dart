import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/features/feed/feed_controller.dart';
import 'package:connect_hub_riverpod/features/feed/widgets/empty_feed.dart';
import 'package:connect_hub_riverpod/features/feed/widgets/post_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The Feed tab.
///
/// It *watches* [feedControllerProvider] to render (Rule 1), *listens* to it
/// for the one-off SnackBar (Rule 3), and *reads* its notifier in callbacks
/// to send the user's intents. Compare ConnectHub-Flutter: a `BlocProvider`
/// to create the Cubit, a `BlocConsumer` to build and listen, and
/// `context.read` in callbacks. Here, nothing creates the controller: the
/// first `watch` does, and it is disposed when the page is.
class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Effects never run in `build`: this callback runs once per new message.
    // `select` narrows the listen to the message alone, so a like or a new
    // page doesn't call it.
    ref.listen(feedControllerProvider.select((feed) => feed.value?.message), (
      _,
      message,
    ) {
      if (message == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      ref.read(feedControllerProvider.notifier).messageShown();
    });

    final feed = ref.watch(feedControllerProvider);
    FeedController controller() => ref.read(feedControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('ConnectHub')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New post',
        onPressed: () => _showComposerComingSoon(context),
        child: const Icon(Icons.edit_outlined),
      ),
      // Data first: a feed with posts stays on screen whatever else is going
      // on. Then loading, *before* the error: after "Try again", Riverpod
      // keeps the failed state (still an `AsyncError`) with `isLoading` set
      // while it loads again, and the screen should show the spinner then.
      body: switch (feed) {
        AsyncValue(value: final state?) when state.posts.isEmpty =>
          RefreshIndicator(
            onRefresh: () => controller().refresh(),
            child: EmptyFeed(
              onCreatePost: () => _showComposerComingSoon(context),
            ),
          ),
        AsyncValue(value: final state?) => PostList(
          state: state,
          onRefresh: () => controller().refresh(),
          onLoadMore: () => controller().loadMore(),
          cardFor: (post) => PostCard(
            key: ValueKey(post.id),
            post: post,
            onLike: () => controller().toggleLike(post),
            onSave: () => controller().toggleSave(post),
          ),
        ),
        AsyncValue(isLoading: true) => const LoadingView(
          message: 'Loading posts…',
        ),
        AsyncError(:final error) => ErrorView(
          message: error is AppException
              ? error.message
              : const UnknownException().message,
          // Throws the failed state away and runs `build` again.
          onRetry: () => ref.invalidate(feedControllerProvider),
        ),
        _ => const LoadingView(message: 'Loading posts…'),
      },
    );
  }

  /// Create Post arrives in Phase 3.
  static void _showComposerComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Creating posts arrives in Phase 3.')),
      );
  }
}
