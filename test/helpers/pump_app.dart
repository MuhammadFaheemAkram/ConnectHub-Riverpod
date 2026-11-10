import 'package:clock/clock.dart';
import 'package:connect_hub_riverpod/core/common/clock_provider.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'backend.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed [MaterialApp] and [Scaffold], which is
  /// enough context for any single design-system widget.
  ///
  /// A `ProviderScope` sits above it, with the clock fixed at [testNow]:
  /// relative times ("1h") read the clock provider.
  Future<void> pumpThemed(Widget widget, {ThemeData? theme}) {
    return pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(Clock.fixed(testNow))],
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          home: Scaffold(body: widget),
        ),
      ),
    );
  }

  /// Renders at a phone-sized 390×844 logical surface (instead of the default
  /// 800×600 test window), so layouts behave as they do on a device. The
  /// original size is restored when the test ends.
  void usePhoneSurface() {
    view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(view.reset);
  }

  /// Taps [finder] and waits for every animation to finish.
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// The index of the selected tab in the shell's [NavigationBar].
  int get selectedTab =>
      widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;
}

/// An [AppBar] whose title is [title], so a test can tell which screen is on
/// top without matching the same text elsewhere (a tab label, a button).
Finder appBarTitled(String title) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(title));
