// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cached notifications, live.

@ProviderFor(cachedNotifications)
final cachedNotificationsProvider = CachedNotificationsProvider._();

/// The cached notifications, live.

final class CachedNotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNotification>>,
          List<AppNotification>,
          Stream<List<AppNotification>>
        >
    with
        $FutureModifier<List<AppNotification>>,
        $StreamProvider<List<AppNotification>> {
  /// The cached notifications, live.
  CachedNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachedNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachedNotificationsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppNotification>> create(Ref ref) {
    return cachedNotifications(ref);
  }
}

String _$cachedNotificationsHash() =>
    r'd204c94ce5f546739377c113268ff0a66f7347dc';

/// How many notifications are unread: the tab badge. A drift `COUNT` query
/// of its own, so the badge rebuilds only when the number changes.

@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// How many notifications are unread: the tab badge. A drift `COUNT` query
/// of its own, so the badge rebuilds only when the number changes.

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// How many notifications are unread: the tab badge. A drift `COUNT` query
  /// of its own, so the badge rebuilds only when the number changes.
  UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return unreadNotificationCount(ref);
  }
}

String _$unreadNotificationCountHash() =>
    r'09c20a2913007dc9b549eaa71390c73721109016';

/// Drives the Notifications tab: the list, the filter, marking read.
///
/// The tab shell listens to it from launch, so the badge is right before
/// the tab is ever opened: the first load runs then, and the controller
/// lives as long as the shell does (the shell's `ref.listen` is its
/// listener). Opened later, the tab finds everything loaded.

@ProviderFor(NotificationsController)
final notificationsControllerProvider = NotificationsControllerProvider._();

/// Drives the Notifications tab: the list, the filter, marking read.
///
/// The tab shell listens to it from launch, so the badge is right before
/// the tab is ever opened: the first load runs then, and the controller
/// lives as long as the shell does (the shell's `ref.listen` is its
/// listener). Opened later, the tab finds everything loaded.
final class NotificationsControllerProvider
    extends
        $AsyncNotifierProvider<NotificationsController, NotificationsState> {
  /// Drives the Notifications tab: the list, the filter, marking read.
  ///
  /// The tab shell listens to it from launch, so the badge is right before
  /// the tab is ever opened: the first load runs then, and the controller
  /// lives as long as the shell does (the shell's `ref.listen` is its
  /// listener). Opened later, the tab finds everything loaded.
  NotificationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsControllerHash();

  @$internal
  @override
  NotificationsController create() => NotificationsController();
}

String _$notificationsControllerHash() =>
    r'5a3165c7f22f17bf8923b8dbad4626249286b87c';

/// Drives the Notifications tab: the list, the filter, marking read.
///
/// The tab shell listens to it from launch, so the badge is right before
/// the tab is ever opened: the first load runs then, and the controller
/// lives as long as the shell does (the shell's `ref.listen` is its
/// listener). Opened later, the tab finds everything loaded.

abstract class _$NotificationsController
    extends $AsyncNotifier<NotificationsState> {
  FutureOr<NotificationsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NotificationsState>, NotificationsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotificationsState>, NotificationsState>,
              AsyncValue<NotificationsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
