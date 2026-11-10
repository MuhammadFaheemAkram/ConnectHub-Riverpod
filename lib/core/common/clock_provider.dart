import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

/// The current time, as a provider, so tests can fix it
/// (`clockProvider.overrideWithValue(Clock.fixed(…))`).
///
/// `keepAlive`: it holds nothing, but what reads it (the fake server, the
/// repositories) lives for the app's lifetime, so it says so too instead of
/// being kept alive only because they happen to watch it.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const Clock();
