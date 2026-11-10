// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'feed_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cached feed window, live: drift's stream as a provider (Rule 5).
///
/// Auto-dispose: it lives while the Feed (through [FeedController]) listens,
/// and its drift query stops when nobody does.

@ProviderFor(feedPosts)
final feedPostsProvider = FeedPostsProvider._();

/// The cached feed window, live: drift's stream as a provider (Rule 5).
///
/// Auto-dispose: it lives while the Feed (through [FeedController]) listens,
/// and its drift query stops when nobody does.

final class FeedPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          Stream<List<Post>>
        >
    with $FutureModifier<List<Post>>, $StreamProvider<List<Post>> {
  /// The cached feed window, live: drift's stream as a provider (Rule 5).
  ///
  /// Auto-dispose: it lives while the Feed (through [FeedController]) listens,
  /// and its drift query stops when nobody does.
  FeedPostsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedPostsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedPostsHash();

  @$internal
  @override
  $StreamProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Post>> create(Ref ref) {
    return feedPosts(ref);
  }
}

String _$feedPostsHash() => r'a502e103c6c7b2cc382c760c9705839e813d783a';

/// Drives the Feed: it shows the window cached in drift at once, refreshes
/// it from the server, pages it in, and likes and saves posts.
///
/// - An `AsyncNotifier`: the first load is asynchronous, and `AsyncValue`
///   gives the screen loading and error for free.
/// - Auto-dispose (the default): it lives while the Feed tab does. The tab
///   shell keeps the tab mounted while the user visits other tabs, so the
///   feed and its scroll position survive tab switches anyway.
/// - The intents are plain methods (`refresh`, `loadMore`, `toggleLike`):
///   the counterpart of ConnectHub-Flutter's Cubit methods, and of the
///   Android edition's MVI intents.
/// - Optimistic likes and saves happen in the repository; this only reports
///   a failure.

@ProviderFor(FeedController)
final feedControllerProvider = FeedControllerProvider._();

/// Drives the Feed: it shows the window cached in drift at once, refreshes
/// it from the server, pages it in, and likes and saves posts.
///
/// - An `AsyncNotifier`: the first load is asynchronous, and `AsyncValue`
///   gives the screen loading and error for free.
/// - Auto-dispose (the default): it lives while the Feed tab does. The tab
///   shell keeps the tab mounted while the user visits other tabs, so the
///   feed and its scroll position survive tab switches anyway.
/// - The intents are plain methods (`refresh`, `loadMore`, `toggleLike`):
///   the counterpart of ConnectHub-Flutter's Cubit methods, and of the
///   Android edition's MVI intents.
/// - Optimistic likes and saves happen in the repository; this only reports
///   a failure.
final class FeedControllerProvider
    extends $AsyncNotifierProvider<FeedController, FeedState> {
  /// Drives the Feed: it shows the window cached in drift at once, refreshes
  /// it from the server, pages it in, and likes and saves posts.
  ///
  /// - An `AsyncNotifier`: the first load is asynchronous, and `AsyncValue`
  ///   gives the screen loading and error for free.
  /// - Auto-dispose (the default): it lives while the Feed tab does. The tab
  ///   shell keeps the tab mounted while the user visits other tabs, so the
  ///   feed and its scroll position survive tab switches anyway.
  /// - The intents are plain methods (`refresh`, `loadMore`, `toggleLike`):
  ///   the counterpart of ConnectHub-Flutter's Cubit methods, and of the
  ///   Android edition's MVI intents.
  /// - Optimistic likes and saves happen in the repository; this only reports
  ///   a failure.
  FeedControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedControllerHash();

  @$internal
  @override
  FeedController create() => FeedController();
}

String _$feedControllerHash() => r'a6f197a76df3d3662609fb6f1c6dcf9e1f051362';

/// Drives the Feed: it shows the window cached in drift at once, refreshes
/// it from the server, pages it in, and likes and saves posts.
///
/// - An `AsyncNotifier`: the first load is asynchronous, and `AsyncValue`
///   gives the screen loading and error for free.
/// - Auto-dispose (the default): it lives while the Feed tab does. The tab
///   shell keeps the tab mounted while the user visits other tabs, so the
///   feed and its scroll position survive tab switches anyway.
/// - The intents are plain methods (`refresh`, `loadMore`, `toggleLike`):
///   the counterpart of ConnectHub-Flutter's Cubit methods, and of the
///   Android edition's MVI intents.
/// - Optimistic likes and saves happen in the repository; this only reports
///   a failure.

abstract class _$FeedController extends $AsyncNotifier<FeedState> {
  FutureOr<FeedState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FeedState>, FeedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FeedState>, FeedState>,
              AsyncValue<FeedState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
