import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/first_value.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/di/use_case_providers.dart';
import 'package:connect_hub_riverpod/domain/model/post.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:connect_hub_riverpod/features/profile/profile_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

/// One cached profile, live (a family by user id).
@riverpod
Stream<User?> cachedUser(Ref ref, String userId) =>
    ref.watch(watchUserUseCaseProvider)(userId);

/// One user's cached posts, newest first, live.
@riverpod
Stream<List<Post>> userPosts(Ref ref, String userId) =>
    ref.watch(watchUserPostsUseCaseProvider)(userId);

/// My saved posts, live from drift: they work offline.
@riverpod
Stream<List<Post>> savedPosts(Ref ref) =>
    ref.watch(watchSavedPostsUseCaseProvider)();

/// Drives a profile, mine or anyone's: a **family** by user id, like Post
/// Detail. My Profile tab and `/users/u_ada` are two members of it.
@riverpod
class ProfileController extends _$ProfileController {
  static const refreshFailedMessage =
      "Couldn't refresh. Showing the saved profile.";
  static const likeFailedMessage =
      "Couldn't update the like. Please try again.";
  static const saveFailedMessage =
      "Couldn't update the save. Please try again.";

  @override
  Future<ProfileState> build(String userId) async {
    // Clear cache bumps the epoch: this rebuilds and loads again.
    ref
      ..watch(cacheEpochProvider)
      ..listen(cachedUserProvider(userId), (_, next) {
        if (next case AsyncData(value: final user?)) {
          _update((profile) => profile.copyWith(user: user));
        }
      })
      ..listen(userPostsProvider(userId), (_, next) {
        if (next case AsyncData(value: final posts)) {
          _update((profile) => profile.copyWith(posts: posts));
        }
      });

    final cached = await _readUser();
    if (cached != null) {
      unawaited(Future(refresh));
      return ProfileState(user: cached, posts: await _readPosts());
    }
    final (user, _) = await _refreshBoth();
    if (user case Err(:final exception)) throw exception;
    final fresh = await _readUser();
    if (fresh == null) throw const NotFoundException();
    return ProfileState(user: fresh, posts: await _readPosts());
  }

  /// Pull to refresh, and the refresh behind the cache.
  Future<void> refresh() async {
    if (!ref.mounted) return;
    final (user, _) = await _refreshBoth();
    if (!ref.mounted) return;
    switch (user) {
      case Err(exception: NotFoundException() && final exception):
        state = AsyncError(exception, StackTrace.current);
      case Err():
        _update((profile) => profile.copyWith(message: refreshFailedMessage));
      case Ok():
        final fresh = await _readUser();
        final posts = await _readPosts();
        if (!ref.mounted || fresh == null) return;
        _update((profile) => profile.copyWith(user: fresh, posts: posts));
    }
  }

  Future<void> toggleLike(Post post) => _report(
    ref.read(likePostUseCaseProvider)(post.id, liked: !post.isLiked),
    likeFailedMessage,
  );

  Future<void> toggleSave(Post post) => _report(
    ref.read(savePostUseCaseProvider)(post.id, saved: !post.isBookmarked),
    saveFailedMessage,
  );

  void messageShown() => _update((profile) => profile.copyWith(message: null));

  Future<void> _report(Future<Result<void>> action, String message) async {
    final result = await action;
    if (!ref.mounted) return;
    if (result is Err<void>) {
      _update((profile) => profile.copyWith(message: message));
    }
  }

  Future<(Result<void>, Result<void>)> _refreshBoth() => (
    ref.read(refreshUserUseCaseProvider)(userId),
    ref.read(refreshUserPostsUseCaseProvider)(userId),
  ).wait;

  Future<User?> _readUser() =>
      ref.read(watchUserUseCaseProvider)(userId).firstValue;

  Future<List<Post>> _readPosts() =>
      ref.read(watchUserPostsUseCaseProvider)(userId).firstValue;

  /// Not while rebuilding (Clear cache): the emptied cache must not replace
  /// what's on screen with "nothing".
  void _update(ProfileState Function(ProfileState profile) change) {
    final profile = state.value;
    if (profile != null && !state.isLoading) state = AsyncData(change(profile));
  }
}

/// My Profile → Saved: offline from drift, refreshed from the server, and
/// unsaving offers Undo.
@riverpod
class SavedPostsController extends _$SavedPostsController {
  static const removedMessage = 'Removed from saved';
  static const refreshFailedMessage =
      "Couldn't refresh. Showing your saved posts.";
  static const saveFailedMessage =
      "Couldn't update the save. Please try again.";

  @override
  Future<SavedPostsState> build() async {
    ref.listen(savedPostsProvider, (_, next) {
      if (next case AsyncData(value: final posts)) {
        _update((saved) => saved.copyWith(posts: posts));
      }
    });
    // Saved posts work offline: whatever is cached shows at once, even
    // nothing, and the server's list follows.
    unawaited(Future(refresh));
    return SavedPostsState(
      posts: await ref.read(watchSavedPostsUseCaseProvider)().firstValue,
    );
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    final result = await ref.read(refreshSavedPostsUseCaseProvider)();
    if (!ref.mounted) return;
    if (result is Err<void>) {
      _update((saved) => saved.copyWith(message: refreshFailedMessage));
    }
  }

  /// Unsaves [post]: it leaves the list at once (the repository's optimistic
  /// write), and the SnackBar offers Undo.
  Future<void> unsave(Post post) async {
    final result = await ref.read(savePostUseCaseProvider)(
      post.id,
      saved: false,
    );
    if (!ref.mounted) return;
    _update(
      (saved) => switch (result) {
        Ok() => saved.copyWith(message: removedMessage, undoable: post),
        Err() => saved.copyWith(message: saveFailedMessage, undoable: null),
      },
    );
  }

  /// Saves [post] again.
  Future<void> undo(Post post) async {
    final result = await ref.read(savePostUseCaseProvider)(
      post.id,
      saved: true,
    );
    if (!ref.mounted) return;
    if (result is Err<void>) {
      _update((saved) => saved.copyWith(message: saveFailedMessage));
    }
  }

  void messageShown() =>
      _update((saved) => saved.copyWith(message: null, undoable: null));

  void _update(SavedPostsState Function(SavedPostsState saved) change) {
    final saved = state.value;
    if (saved != null && !state.isLoading) state = AsyncData(change(saved));
  }
}
