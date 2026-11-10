// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'post_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One cached post, live: a **family** keyed by the post id. Each id gets its
/// own provider (and drift query), disposed when nothing watches it.

@ProviderFor(cachedPost)
final cachedPostProvider = CachedPostFamily._();

/// One cached post, live: a **family** keyed by the post id. Each id gets its
/// own provider (and drift query), disposed when nothing watches it.

final class CachedPostProvider
    extends $FunctionalProvider<AsyncValue<Post?>, Post?, Stream<Post?>>
    with $FutureModifier<Post?>, $StreamProvider<Post?> {
  /// One cached post, live: a **family** keyed by the post id. Each id gets its
  /// own provider (and drift query), disposed when nothing watches it.
  CachedPostProvider._({
    required CachedPostFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cachedPostProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cachedPostHash();

  @override
  String toString() {
    return r'cachedPostProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Post?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Post?> create(Ref ref) {
    final argument = this.argument as String;
    return cachedPost(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CachedPostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cachedPostHash() => r'8a9c90cc51863542e7d71d909905d223c685abd0';

/// One cached post, live: a **family** keyed by the post id. Each id gets its
/// own provider (and drift query), disposed when nothing watches it.

final class CachedPostFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Post?>, String> {
  CachedPostFamily._()
    : super(
        retry: null,
        name: r'cachedPostProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One cached post, live: a **family** keyed by the post id. Each id gets its
  /// own provider (and drift query), disposed when nothing watches it.

  CachedPostProvider call(String postId) =>
      CachedPostProvider._(argument: postId, from: this);

  @override
  String toString() => r'cachedPostProvider';
}

/// The cached comments on one post, live, oldest first.

@ProviderFor(postComments)
final postCommentsProvider = PostCommentsFamily._();

/// The cached comments on one post, live, oldest first.

final class PostCommentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Comment>>,
          List<Comment>,
          Stream<List<Comment>>
        >
    with $FutureModifier<List<Comment>>, $StreamProvider<List<Comment>> {
  /// The cached comments on one post, live, oldest first.
  PostCommentsProvider._({
    required PostCommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postCommentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postCommentsHash();

  @override
  String toString() {
    return r'postCommentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Comment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Comment>> create(Ref ref) {
    final argument = this.argument as String;
    return postComments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postCommentsHash() => r'dc6a8fcf2b8e8cdccc9437db26429cee56d895bc';

/// The cached comments on one post, live, oldest first.

final class PostCommentsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Comment>>, String> {
  PostCommentsFamily._()
    : super(
        retry: null,
        name: r'postCommentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The cached comments on one post, live, oldest first.

  PostCommentsProvider call(String postId) =>
      PostCommentsProvider._(argument: postId, from: this);

  @override
  String toString() => r'postCommentsProvider';
}

/// Drives Post Detail: one post, its comments, the comment input.
///
/// - **A family:** `postDetailControllerProvider('p1')` and
///   `postDetailControllerProvider('p2')` are separate controllers with
///   separate state. ConnectHub-Flutter passed the id through get_it's
///   `@factoryParam`; here it is the provider's argument, and the generated
///   notifier exposes it as [postId].
/// - **Auto-dispose:** leaving the page frees the controller (and its two
///   drift queries); opening the post again starts from the cache.
/// - Like the Feed, it shows the cache at once and refreshes behind it.

@ProviderFor(PostDetailController)
final postDetailControllerProvider = PostDetailControllerFamily._();

/// Drives Post Detail: one post, its comments, the comment input.
///
/// - **A family:** `postDetailControllerProvider('p1')` and
///   `postDetailControllerProvider('p2')` are separate controllers with
///   separate state. ConnectHub-Flutter passed the id through get_it's
///   `@factoryParam`; here it is the provider's argument, and the generated
///   notifier exposes it as [postId].
/// - **Auto-dispose:** leaving the page frees the controller (and its two
///   drift queries); opening the post again starts from the cache.
/// - Like the Feed, it shows the cache at once and refreshes behind it.
final class PostDetailControllerProvider
    extends $AsyncNotifierProvider<PostDetailController, PostDetailState> {
  /// Drives Post Detail: one post, its comments, the comment input.
  ///
  /// - **A family:** `postDetailControllerProvider('p1')` and
  ///   `postDetailControllerProvider('p2')` are separate controllers with
  ///   separate state. ConnectHub-Flutter passed the id through get_it's
  ///   `@factoryParam`; here it is the provider's argument, and the generated
  ///   notifier exposes it as [postId].
  /// - **Auto-dispose:** leaving the page frees the controller (and its two
  ///   drift queries); opening the post again starts from the cache.
  /// - Like the Feed, it shows the cache at once and refreshes behind it.
  PostDetailControllerProvider._({
    required PostDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postDetailControllerHash();

  @override
  String toString() {
    return r'postDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PostDetailController create() => PostDetailController();

  @override
  bool operator ==(Object other) {
    return other is PostDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postDetailControllerHash() =>
    r'63b3636836d983355054c85d4c605c9fc815e476';

/// Drives Post Detail: one post, its comments, the comment input.
///
/// - **A family:** `postDetailControllerProvider('p1')` and
///   `postDetailControllerProvider('p2')` are separate controllers with
///   separate state. ConnectHub-Flutter passed the id through get_it's
///   `@factoryParam`; here it is the provider's argument, and the generated
///   notifier exposes it as [postId].
/// - **Auto-dispose:** leaving the page frees the controller (and its two
///   drift queries); opening the post again starts from the cache.
/// - Like the Feed, it shows the cache at once and refreshes behind it.

final class PostDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PostDetailController,
          AsyncValue<PostDetailState>,
          PostDetailState,
          FutureOr<PostDetailState>,
          String
        > {
  PostDetailControllerFamily._()
    : super(
        retry: null,
        name: r'postDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives Post Detail: one post, its comments, the comment input.
  ///
  /// - **A family:** `postDetailControllerProvider('p1')` and
  ///   `postDetailControllerProvider('p2')` are separate controllers with
  ///   separate state. ConnectHub-Flutter passed the id through get_it's
  ///   `@factoryParam`; here it is the provider's argument, and the generated
  ///   notifier exposes it as [postId].
  /// - **Auto-dispose:** leaving the page frees the controller (and its two
  ///   drift queries); opening the post again starts from the cache.
  /// - Like the Feed, it shows the cache at once and refreshes behind it.

  PostDetailControllerProvider call(String postId) =>
      PostDetailControllerProvider._(argument: postId, from: this);

  @override
  String toString() => r'postDetailControllerProvider';
}

/// Drives Post Detail: one post, its comments, the comment input.
///
/// - **A family:** `postDetailControllerProvider('p1')` and
///   `postDetailControllerProvider('p2')` are separate controllers with
///   separate state. ConnectHub-Flutter passed the id through get_it's
///   `@factoryParam`; here it is the provider's argument, and the generated
///   notifier exposes it as [postId].
/// - **Auto-dispose:** leaving the page frees the controller (and its two
///   drift queries); opening the post again starts from the cache.
/// - Like the Feed, it shows the cache at once and refreshes behind it.

abstract class _$PostDetailController extends $AsyncNotifier<PostDetailState> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  FutureOr<PostDetailState> build(String postId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PostDetailState>, PostDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PostDetailState>, PostDetailState>,
              AsyncValue<PostDetailState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
