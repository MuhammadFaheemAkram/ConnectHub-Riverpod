import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub_riverpod/domain/model/comment.dart';
import 'package:connect_hub_riverpod/features/post_detail/post_detail_controller.dart';
import 'package:connect_hub_riverpod/features/post_detail/post_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// One post, its comments inline, and a comment input at the bottom.
///
/// A `ConsumerStatefulWidget`: Riverpod's `StatefulWidget`, with `ref`
/// available everywhere in the `State`. It needs state of its own for three
/// UI objects: the input's controller (cleared after a sent comment, kept on
/// failure), the list's scroll controller (which then scrolls to the
/// comment) and the input's focus (the comment button focuses it).
class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _comment = TextEditingController();
  final _scroll = ScrollController();
  final _commentFocus = FocusNode();

  /// This post's controller: the family member for [PostDetailPage.postId].
  PostDetailControllerProvider get _provider =>
      postDetailControllerProvider(widget.postId);

  PostDetailController get _controller => ref.read(_provider.notifier);

  @override
  void dispose() {
    _comment.dispose();
    _scroll.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // One-off effects, each from its own slice of the state (Rule 3).
    ref
      ..listen(_provider.select((detail) => detail.value?.message), (
        _,
        message,
      ) {
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        _controller.messageShown();
      })
      ..listen(_provider.select((detail) => detail.value?.sentCount ?? 0), (
        previous,
        sent,
      ) {
        if (sent > (previous ?? 0)) {
          _comment.clear();
          unawaited(_scrollToNewest());
        }
      });

    final detail = ref.watch(_provider);
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton(),
        title: const Text('Post'),
      ),
      body: switch (detail) {
        AsyncValue(value: final state?) => Column(
          children: [
            Expanded(child: _postAndComments(state)),
            ComposerBar(
              controller: _comment,
              focusNode: _commentFocus,
              isSending: state.isSending,
              onSend: _controller.sendComment,
            ),
          ],
        ),
        AsyncValue(isLoading: true) => const LoadingView(
          message: 'Loading post…',
        ),
        AsyncError(error: NotFoundException()) => const EmptyStateView(
          icon: Icons.article_outlined,
          title: 'This post is no longer available.',
        ),
        AsyncError(:final error) => ErrorView(
          message: error is AppException
              ? error.message
              : const UnknownException().message,
          onRetry: () => ref.invalidate(_provider),
        ),
        _ => const LoadingView(message: 'Loading post…'),
      },
    );
  }

  /// The post, then "Comments" and every comment, oldest first; pull to
  /// refresh.
  Widget _postAndComments(PostDetailState state) {
    final theme = Theme.of(context);
    final controller = _controller;
    final post = state.post;
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: PostCard(
              post: post,
              onLike: () => controller.toggleLike(post),
              onComment: _commentFocus.requestFocus,
              onSave: () => controller.toggleSave(post),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.medium,
              AppSpacing.medium,
              AppSpacing.xxSmall,
            ),
            child: Text('Comments', style: theme.textTheme.titleMedium),
          ),
          if (state.comments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Text(
                'No comments yet. Be the first to comment.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final comment in state.comments)
              CommentTile(
                key: ValueKey(comment.id),
                comment: comment,
                onLike: () => controller.toggleCommentLike(comment),
                onDelete: comment.isMine ? () => _confirmDelete(comment) : null,
              ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Comment comment) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete comment?',
      message: 'It will be removed for everyone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) await _controller.deleteComment(comment);
  }

  /// The new comment is the last one: scroll to the end of the list.
  ///
  /// A lazy list only estimates its full height until its last items are
  /// built, so one scroll to the "end" can stop short (seen on the
  /// simulator, with the keyboard up). Each pass builds more of the list;
  /// a few passes reach the real end.
  Future<void> _scrollToNewest() async {
    for (var pass = 0; pass < 3; pass++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !_scroll.hasClients) return;
      final position = _scroll.position;
      if (position.pixels >= position.maxScrollExtent) return;
      await _scroll.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }
}
