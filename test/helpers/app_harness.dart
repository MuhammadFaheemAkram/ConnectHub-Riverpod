import 'package:connect_hub_riverpod/app/connect_hub_app.dart';
import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:connect_hub_riverpod/core/navigation/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_app.dart';

/// Pumps the whole app, as `main` does, on a phone-sized surface.
///
/// - [overrides] replace providers for this test only: the Riverpod
///   counterpart of registering fakes in get_it before a test.
/// - [at] opens a deep link through the app's own router.
///
/// Returns the [ProviderContainer] behind the app's `ProviderScope`, so a
/// test can read the same providers the widgets watch. The scope, and every
/// provider in it, is disposed with the widget tree when the test ends.
Future<ProviderContainer> pumpConnectHub(
  WidgetTester tester, {
  String? at,
  List<Override> overrides = const [],
}) async {
  tester.usePhoneSurface();
  await tester.pumpWidget(
    ProviderScope(
      retry: noAutomaticRetry,
      overrides: overrides,
      child: const ConnectHubApp(),
    ),
  );
  final container = ProviderScope.containerOf(
    tester.element(find.byType(ConnectHubApp)),
  );
  if (at != null) container.read(appRouterProvider).go(at);
  await tester.pumpAndSettle();
  return container;
}
