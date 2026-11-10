// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's id: the demo user, always (sign-in is out of scope
/// in every edition).
///
/// A provider rather than a constant, so the code that needs "who am I"
/// (my comments, my profile's redirect) depends on one place a real session
/// would replace, and a test can sign in as someone else.

@ProviderFor(signedInUserId)
final signedInUserIdProvider = SignedInUserIdProvider._();

/// The signed-in user's id: the demo user, always (sign-in is out of scope
/// in every edition).
///
/// A provider rather than a constant, so the code that needs "who am I"
/// (my comments, my profile's redirect) depends on one place a real session
/// would replace, and a test can sign in as someone else.

final class SignedInUserIdProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The signed-in user's id: the demo user, always (sign-in is out of scope
  /// in every edition).
  ///
  /// A provider rather than a constant, so the code that needs "who am I"
  /// (my comments, my profile's redirect) depends on one place a real session
  /// would replace, and a test can sign in as someone else.
  SignedInUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signedInUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signedInUserIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return signedInUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$signedInUserIdHash() => r'e4af4e2434b8d7f216bc04d3064183fbe0d27803';
