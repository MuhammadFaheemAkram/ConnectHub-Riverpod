import 'package:connect_hub_riverpod/app/connect_hub_app.dart';
import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:connect_hub_riverpod/core/navigation/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'backend.dart';
import 'pump_app.dart';

/// Pumps the whole app, as `main` does, on a phone-sized surface.
///
/// - [overrides] replace providers for this test only: the Riverpod
///   counterpart of registering fakes in get_it before a test. By default,
///   the real stack with a fixed clock, no latency and an in-memory database
///   ([realStack]); a test that needs more passes
///   `[...realStack(), someProvider.overrideWithValue(fake)]`.
/// - [at] opens a deep link through the app's own router.
/// - [settle]: wait for every animation to end. A screen that stays on a
///   spinner never settles (conventions §11.7): pass `false`, and the app is
///   pumped for one frame instead.
///
/// Returns the [ProviderContainer] behind the app's `ProviderScope`, so a
/// test can read the same providers the widgets watch. The scope, and every
/// provider in it (the database included), is disposed with the widget tree
/// when the test ends.
Future<ProviderContainer> pumpConnectHub(
  WidgetTester tester, {
  String? at,
  List<Override>? overrides,
  bool settle = true,
}) async {
  tester.usePhoneSurface();
  await tester.pumpWidget(
    ProviderScope(
      retry: noAutomaticRetry,
      overrides: overrides ?? realStack(),
      child: const ConnectHubApp(),
    ),
  );
  final container = ProviderScope.containerOf(
    tester.element(find.byType(ConnectHubApp)),
  );
  if (at != null) container.read(appRouterProvider).go(at);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return container;
}
