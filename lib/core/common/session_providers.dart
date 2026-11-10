import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_providers.g.dart';

/// The signed-in user's id: the demo user, always (sign-in is out of scope
/// in every edition).
///
/// A provider rather than a constant, so the code that needs "who am I"
/// (my comments, my profile's redirect) depends on one place a real session
/// would replace, and a test can sign in as someone else.
@Riverpod(keepAlive: true)
String signedInUserId(Ref ref) => 'u_demo';
