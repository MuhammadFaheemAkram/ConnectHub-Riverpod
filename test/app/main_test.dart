import 'package:connect_hub_riverpod/app/connect_hub_app.dart';
import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:connect_hub_riverpod/main.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

// The other app tests build their own ProviderScope (with overrides); this
// one runs the real `main`.
void main() {
  testWidgets('main runs the app in a ProviderScope with automatic retry '
      'off', (tester) async {
    tester.usePhoneSurface();

    app.main();
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConnectHubApp)),
    );
    expect(container.retry, same(noAutomaticRetry));
    expect(appBarTitled('ConnectHub'), findsOneWidget);

    // The real app goes on to open its database on disk and wait out real
    // latencies; this test stops it there, and lets the requests already on
    // the (simulated) wire land.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
