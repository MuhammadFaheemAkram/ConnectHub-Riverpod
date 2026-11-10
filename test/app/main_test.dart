import 'package:connect_hub_riverpod/app/connect_hub_app.dart';
import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:connect_hub_riverpod/core/storage/preferences_store.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/main.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../helpers/pump_app.dart';

// The other app tests build their own ProviderScope (with overrides); this
// one runs the real `main`, with the preferences' platform in memory. Once:
// the real app opens its database on disk, and a second run in the same
// file would open another.
void main() {
  testWidgets('main opens the preferences before runApp, injects them, and '
      'runs the app with automatic retry off', (tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tester.usePhoneSurface();

    // main awaits the preferences before runApp. The in-memory platform
    // answers in microtasks, so this runs in the test's fake time.
    await app.main();
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConnectHubApp)),
    );
    expect(container.retry, same(noAutomaticRetry));
    expect(
      container.read(preferencesStoreProvider),
      isA<SharedPreferencesStore>(),
    );
    expect(appBarTitled('ConnectHub'), findsOneWidget);

    // The real app goes on to wait out real latencies; this test stops it
    // there, and lets the requests already on the (simulated) wire land.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
