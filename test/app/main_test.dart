import 'package:connect_hub_riverpod/app/connect_hub_app.dart';
import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:connect_hub_riverpod/main.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

// The other app tests build their own ProviderScope (with overrides); this
// one runs the real `main`.
void main() {
  testWidgets('main runs the app in a ProviderScope with automatic retry '
      'off', (tester) async {
    tester.usePhoneSurface();

    app.main();
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConnectHubApp)),
    );
    expect(container.retry, same(noAutomaticRetry));
    expect(appBarTitled('ConnectHub'), findsOneWidget);
  });
}
