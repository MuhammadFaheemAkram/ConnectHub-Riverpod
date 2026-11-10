import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

/// A profile once it's there. Loading, "couldn't load" and "isn't
/// available" are the `AsyncValue` around it.
@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    required User user,

    /// Their posts, newest first.
    @Default(<Post>[]) List<Post> posts,

    /// A one-off SnackBar, consumed by `messageShown()`.
    String? message,
  }) = _ProfileState;
}

/// My saved posts.
@freezed
abstract class SavedPostsState with _$SavedPostsState {
  const factory SavedPostsState({
    /// The most recently saved first.
    @Default(<Post>[]) List<Post> posts,

    /// A one-off SnackBar.
    String? message,

    /// The post just unsaved: the SnackBar offers Undo for it.
    Post? undoable,
  }) = _SavedPostsState;
}
