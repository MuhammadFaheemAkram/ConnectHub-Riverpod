import 'package:connect_hub_riverpod/core/common/form_status.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/use_case_providers.dart';
import 'package:connect_hub_riverpod/features/create_post/create_post_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_post_controller.g.dart';

/// Drives the New post form.
///
/// A synchronous `Notifier`, not an `AsyncNotifier`: the form has nothing to
/// load, so `build` returns the empty form at once. The one asynchronous
/// action, [submit], is tracked in the state's `status`. Auto-dispose: the
/// draft goes with the page (after "Discard post?").
@riverpod
class CreatePostController extends _$CreatePostController {
  @override
  CreatePostState build() => const CreatePostState();

  void contentChanged(String value) =>
      state = _edited(state.copyWith(content: value));

  void imageUrlChanged(String value) =>
      state = _edited(state.copyWith(imageUrl: value));

  /// Publishes the post. On success the status becomes `success` and the
  /// page closes; on failure the input stays and the server's message shows.
  Future<void> submit() async {
    if (!state.canSubmit) return;
    state = state.copyWith(status: FormStatus.submitting, errorMessage: null);
    final result = await ref.read(createPostUseCaseProvider)(
      content: state.content,
      imageUrl: state.imageUrl,
    );
    if (!ref.mounted) return;
    state = switch (result) {
      Ok() => state.copyWith(status: FormStatus.success),
      Err(:final exception) => state.copyWith(
        status: FormStatus.failure,
        errorMessage: exception.message,
      ),
    };
  }

  /// Editing after a failure starts over: the old error no longer applies.
  CreatePostState _edited(CreatePostState next) =>
      next.status == FormStatus.failure
      ? next.copyWith(status: FormStatus.idle, errorMessage: null)
      : next;
}
