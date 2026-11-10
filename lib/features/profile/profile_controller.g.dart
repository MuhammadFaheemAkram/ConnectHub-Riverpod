// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One cached profile, live (a family by user id).

@ProviderFor(cachedUser)
final cachedUserProvider = CachedUserFamily._();

/// One cached profile, live (a family by user id).

final class CachedUserProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// One cached profile, live (a family by user id).
  CachedUserProvider._({
    required CachedUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cachedUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cachedUserHash();

  @override
  String toString() {
    return r'cachedUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    final argument = this.argument as String;
    return cachedUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CachedUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cachedUserHash() => r'ac19b68c1a26e48d09eb30c1fe42798453422563';

/// One cached profile, live (a family by user id).

final class CachedUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<User?>, String> {
  CachedUserFamily._()
    : super(
        retry: null,
        name: r'cachedUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One cached profile, live (a family by user id).

  CachedUserProvider call(String userId) =>
      CachedUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'cachedUserProvider';
}

/// One user's cached posts, newest first, live.

@ProviderFor(userPosts)
final userPostsProvider = UserPostsFamily._();

/// One user's cached posts, newest first, live.

final class UserPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          Stream<List<Post>>
        >
    with $FutureModifier<List<Post>>, $StreamProvider<List<Post>> {
  /// One user's cached posts, newest first, live.
  UserPostsProvider._({
    required UserPostsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userPostsHash();

  @override
  String toString() {
    return r'userPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Post>> create(Ref ref) {
    final argument = this.argument as String;
    return userPosts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userPostsHash() => r'23febbcbfb0f30a5e375268a96ffb4ab059a5aa3';

/// One user's cached posts, newest first, live.

final class UserPostsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Post>>, String> {
  UserPostsFamily._()
    : super(
        retry: null,
        name: r'userPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One user's cached posts, newest first, live.

  UserPostsProvider call(String userId) =>
      UserPostsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userPostsProvider';
}

/// My saved posts, live from drift: they work offline.

@ProviderFor(savedPosts)
final savedPostsProvider = SavedPostsProvider._();

/// My saved posts, live from drift: they work offline.

final class SavedPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          Stream<List<Post>>
        >
    with $FutureModifier<List<Post>>, $StreamProvider<List<Post>> {
  /// My saved posts, live from drift: they work offline.
  SavedPostsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedPostsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedPostsHash();

  @$internal
  @override
  $StreamProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Post>> create(Ref ref) {
    return savedPosts(ref);
  }
}

String _$savedPostsHash() => r'711e26f39e22456dca87496f22e51796f18dcf8f';

/// Drives a profile, mine or anyone's: a **family** by user id, like Post
/// Detail. My Profile tab and `/users/u_ada` are two members of it.

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerFamily._();

/// Drives a profile, mine or anyone's: a **family** by user id, like Post
/// Detail. My Profile tab and `/users/u_ada` are two members of it.
final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, ProfileState> {
  /// Drives a profile, mine or anyone's: a **family** by user id, like Post
  /// Detail. My Profile tab and `/users/u_ada` are two members of it.
  ProfileControllerProvider._({
    required ProfileControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @override
  String toString() {
    return r'profileControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileController create() => ProfileController();

  @override
  bool operator ==(Object other) {
    return other is ProfileControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileControllerHash() => r'5e0a1269b0ca4dae2b93d824c59ac431535de6a4';

/// Drives a profile, mine or anyone's: a **family** by user id, like Post
/// Detail. My Profile tab and `/users/u_ada` are two members of it.

final class ProfileControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileController,
          AsyncValue<ProfileState>,
          ProfileState,
          FutureOr<ProfileState>,
          String
        > {
  ProfileControllerFamily._()
    : super(
        retry: null,
        name: r'profileControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives a profile, mine or anyone's: a **family** by user id, like Post
  /// Detail. My Profile tab and `/users/u_ada` are two members of it.

  ProfileControllerProvider call(String userId) =>
      ProfileControllerProvider._(argument: userId, from: this);

  @override
  String toString() => r'profileControllerProvider';
}

/// Drives a profile, mine or anyone's: a **family** by user id, like Post
/// Detail. My Profile tab and `/users/u_ada` are two members of it.

abstract class _$ProfileController extends $AsyncNotifier<ProfileState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<ProfileState> build(String userId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ProfileState>, ProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProfileState>, ProfileState>,
              AsyncValue<ProfileState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// My Profile → Saved: offline from drift, refreshed from the server, and
/// unsaving offers Undo.

@ProviderFor(SavedPostsController)
final savedPostsControllerProvider = SavedPostsControllerProvider._();

/// My Profile → Saved: offline from drift, refreshed from the server, and
/// unsaving offers Undo.
final class SavedPostsControllerProvider
    extends $AsyncNotifierProvider<SavedPostsController, SavedPostsState> {
  /// My Profile → Saved: offline from drift, refreshed from the server, and
  /// unsaving offers Undo.
  SavedPostsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedPostsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedPostsControllerHash();

  @$internal
  @override
  SavedPostsController create() => SavedPostsController();
}

String _$savedPostsControllerHash() =>
    r'b401ded0ef0f42ede7d24027aa9ad09736a2340c';

/// My Profile → Saved: offline from drift, refreshed from the server, and
/// unsaving offers Undo.

abstract class _$SavedPostsController extends $AsyncNotifier<SavedPostsState> {
  FutureOr<SavedPostsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SavedPostsState>, SavedPostsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SavedPostsState>, SavedPostsState>,
              AsyncValue<SavedPostsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
