import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';

// Every screen, in light and dark, with text at 200%: no layout overflows
// (an overflow fails the test), tap targets of at least 48 × 48, a label on
// everything tappable, and readable text. Each phase adds its screens and
// states here.
void main() {
  for (final brightness in Brightness.values) {
    group('${brightness.name} theme, text at 200%', () {
      Future<void> open(WidgetTester tester, String location) async {
        tester.platformDispatcher
          ..textScaleFactorTestValue = 2
          ..platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await pumpConnectHub(tester, at: location);
        final context = tester.element(find.byType(Scaffold).last);
        expect(MediaQuery.textScalerOf(context).scale(10), 20);
        expect(Theme.of(context).brightness, brightness);
      }

      Future<void> expectAccessible(WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      }

      for (final (name, location) in [
        ('Feed', '/feed'),
        ('Search', '/search'),
        ('Notifications', '/notifications'),
        ('Profile', '/profile'),
        ('Settings', '/settings'),
        ('Page not found', '/nowhere'),
      ]) {
        testWidgets(name, (tester) async {
          await open(tester, location);

          await expectAccessible(tester);
        });
      }
    });
  }
}
