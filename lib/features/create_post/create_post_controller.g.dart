// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'create_post_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the New post form.
///
/// A synchronous `Notifier`, not an `AsyncNotifier`: the form has nothing to
/// load, so `build` returns the empty form at once. The one asynchronous
/// action, [submit], is tracked in the state's `status`. Auto-dispose: the
/// draft goes with the page (after "Discard post?").

@ProviderFor(CreatePostController)
final createPostControllerProvider = CreatePostControllerProvider._();

/// Drives the New post form.
///
/// A synchronous `Notifier`, not an `AsyncNotifier`: the form has nothing to
/// load, so `build` returns the empty form at once. The one asynchronous
/// action, [submit], is tracked in the state's `status`. Auto-dispose: the
/// draft goes with the page (after "Discard post?").
final class CreatePostControllerProvider
    extends $NotifierProvider<CreatePostController, CreatePostState> {
  /// Drives the New post form.
  ///
  /// A synchronous `Notifier`, not an `AsyncNotifier`: the form has nothing to
  /// load, so `build` returns the empty form at once. The one asynchronous
  /// action, [submit], is tracked in the state's `status`. Auto-dispose: the
  /// draft goes with the page (after "Discard post?").
  CreatePostControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPostControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPostControllerHash();

  @$internal
  @override
  CreatePostController create() => CreatePostController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePostState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePostState>(value),
    );
  }
}

String _$createPostControllerHash() =>
    r'083063991b4bbdf4742e7b7197e793c8e87284c2';

/// Drives the New post form.
///
/// A synchronous `Notifier`, not an `AsyncNotifier`: the form has nothing to
/// load, so `build` returns the empty form at once. The one asynchronous
/// action, [submit], is tracked in the state's `status`. Auto-dispose: the
/// draft goes with the page (after "Discard post?").

abstract class _$CreatePostController extends $Notifier<CreatePostState> {
  CreatePostState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreatePostState, CreatePostState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreatePostState, CreatePostState>,
              CreatePostState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
