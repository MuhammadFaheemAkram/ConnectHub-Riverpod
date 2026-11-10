import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/features/feed/feed_state.dart';
import 'package:material_ui/material_ui.dart';

/// The posts, with pull to refresh and infinite scroll.
///
/// Stateful only for its `ScrollController`, the one piece of UI state it
/// owns: when the user nears the end, it asks for the next page.
class PostList extends StatefulWidget {
  const PostList({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.cardFor,
  });

  final FeedState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final Widget Function(Post post) cardFor;

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final _scroll = ScrollController();

  /// "Near the end": less than about a screen of posts left below.
  static const _loadMoreDistance = 600.0;

  @override
  void initState() {
    super.initState();
    // Scrolling near the end asks for the next page. The first layout needs
    // no extra check: it reports its scroll metrics (see `build`).
    _scroll.addListener(_loadMoreIfNearEnd);
  }

  @override
  void didUpdateWidget(PostList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A page can arrive without the user scrolling, or add nothing new (e.g.
    // posts already cached). Check again once it is laid out, so a list
    // that is still short keeps loading.
    final old = oldWidget.state;
    final current = widget.state;
    if (old.posts.length != current.posts.length ||
        old.loadMore != current.loadMore) {
      _checkAfterLayout();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _checkAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadMoreIfNearEnd();
    });
  }

  void _loadMoreIfNearEnd() {
    final state = widget.state;
    // A failed page waits for the footer's Retry instead of retrying in a
    // loop; a finished feed has nothing more to load.
    if (state.loadMore != LoadMoreStatus.idle) return;
    if (!_scroll.hasClients) return;
    if (_scroll.position.extentAfter < _loadMoreDistance) widget.onLoadMore();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final posts = state.posts;
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      // The viewport or the content can change size without any scrolling (a
      // rotation, a resized window, a different text size). Check again then
      // too: a list that suddenly fits on screen would otherwise show its
      // footer spinner forever, with nothing to scroll.
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) {
          _loadMoreIfNearEnd();
          return false;
        },
        child: ListView.separated(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          // Bottom padding keeps the last post clear of the FAB.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.xSmall,
            AppSpacing.medium,
            AppSpacing.xLarge * 3,
          ),
          itemCount: posts.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.small),
          itemBuilder: (context, index) => index < posts.length
              ? widget.cardFor(posts[index])
              : _FeedFooter(status: state.loadMore, onRetry: widget.onLoadMore),
        ),
      ),
    );
  }
}

/// The end of the list: a spinner while there is more, "Couldn't load more
/// · Retry" after a failure, and "You're all caught up" at the very end.
class _FeedFooter extends StatelessWidget {
  const _FeedFooter({required this.status, required this.onRetry});

  final LoadMoreStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiet = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    if (status == LoadMoreStatus.done) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
        child: Text(
          "You're all caught up",
          style: quiet,
          textAlign: TextAlign.center,
        ),
      );
    }
    if (status == LoadMoreStatus.failed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("Couldn't load more", style: quiet),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
      child: Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            semanticsLabel: 'Loading more posts',
          ),
        ),
      ),
    );
  }
}
