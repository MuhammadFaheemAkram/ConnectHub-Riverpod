import 'package:connect_hub_riverpod/core/common/form_status.dart';
import 'package:connect_hub_riverpod/core/common/validators.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/app_routes.dart';
import 'package:connect_hub_riverpod/features/create_post/create_post_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The New post form, shown as a full-screen dialog.
///
/// Leaving with a draft (the close button, the system back gesture) first
/// asks "Discard post?": the button asks itself, and [PopScope] catches the
/// back gesture. A published post closes the
/// page from `ref.listen`, never from `build`.
class CreatePostPage extends ConsumerWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(createPostControllerProvider.select((form) => form.status), (
      _,
      status,
    ) {
      if (status == FormStatus.success) _close(context);
    });

    final form = ref.watch(createPostControllerProvider);
    final controller = ref.read(createPostControllerProvider.notifier);
    final theme = Theme.of(context);
    final errorMessage = form.errorMessage;
    return PopScope(
      // Nothing to lose, or already published: leave freely.
      canPop: !form.hasDraft || form.status == FormStatus.success,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave(context, hasDraft: true);
      },
      child: Scaffold(
        appBar: AppBar(
          // Not `BackToFeedButton`: opened by a link, it would `go` to the
          // feed, which no `PopScope` sees, and lose the draft unasked.
          leading: IconButton(
            tooltip: 'Close',
            icon: const CloseButtonIcon(),
            onPressed: () => _leave(
              context,
              hasDraft: form.hasDraft && form.status != FormStatus.success,
            ),
          ),
          title: const Text('New post'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xSmall),
              child: FilledButton(
                onPressed: form.canSubmit ? controller.submit : null,
                child: form.status == FormStatus.submitting
                    ? const ButtonProgress(semanticsLabel: 'Posting')
                    : const Text('Post'),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.medium),
          children: [
            TextField(
              autofocus: true,
              enabled: !form.isBusy,
              minLines: 5,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              onChanged: controller.contentChanged,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                errorText: form.contentError,
              ),
            ),
            const SizedBox(height: AppSpacing.xxSmall),
            Align(
              alignment: Alignment.centerRight,
              child: CharacterCounter(
                count: form.length,
                max: Validators.postMaxLength,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            AppTextField(
              label: 'Image URL (optional)',
              hintText: 'https://…',
              errorText: form.imageUrlError,
              enabled: !form.isBusy,
              keyboardType: TextInputType.url,
              onChanged: controller.imageUrlChanged,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.medium),
              Text(
                errorMessage,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Leaves the page, asking "Discard post?" first if there is a draft:
  /// from the close button and the system back gesture alike, however the
  /// page was opened.
  static Future<void> _leave(
    BuildContext context, {
    required bool hasDraft,
  }) async {
    if (hasDraft && !await _confirmDiscard(context)) return;
    if (context.mounted) _close(context);
  }

  static Future<bool> _confirmDiscard(BuildContext context) =>
      showConfirmationDialog(
        context,
        title: 'Discard post?',
        message: "What you've written will be lost.",
        confirmLabel: 'Discard',
        isDestructive: true,
      );

  /// `pop()` closes the page even while a `PopScope` holds a draft: it is
  /// only called after publishing or confirming the discard. Opened directly
  /// (a deep link), there is nothing underneath, so it goes to the Feed
  /// (conventions §11.47).
  static void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      const FeedRoute().go(context);
    }
  }
}
