import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/pump_app.dart';

// Search end to end, on the real provider graph: the fake server's search,
// drift, the debounced providers and the page.
void main() {
  final field = find.byType(TextField);

  Finder tab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Finder onCard(Finder post, Finder target) => find.descendant(
    of: find.ancestor(of: post, matching: find.byType(Card)),
    matching: target,
  );

  Future<void> searchFor(WidgetTester tester, String query) async {
    await tester.enterText(field, query);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  // p1, Ada Lovelace's newest post.
  final p1 = find.textContaining('analytical engine scheduler');

  testWidgets('finds people and posts on the server', (tester) async {
    await pumpConnectHub(tester, at: '/search');

    await searchFor(tester, 'ada');

    expect(find.text('Ada Lovelace'), findsWidgets);
    expect(p1, findsOneWidget);
  });

  testWidgets('a like in the results shows on the feed: the same drift row', (
    tester,
  ) async {
    await pumpConnectHub(tester, at: '/search');
    await searchFor(tester, 'ada');

    // People come first, so p1's buttons start below the screen's edge
    // (a tap there would miss silently, conventions §11.51).
    await tester.ensureVisible(onCard(p1, find.byTooltip('Like')));
    await tester.pumpAndSettle();
    await tester.tapAndSettle(onCard(p1, find.byTooltip('Like')));
    expect(onCard(p1, find.text('143')), findsOneWidget);

    await tester.tapAndSettle(tab('Feed'));
    expect(onCard(p1, find.byTooltip('Unlike')), findsOneWidget);
  });

  testWidgets('the query and its results survive a trip to another tab', (
    tester,
  ) async {
    await pumpConnectHub(tester, at: '/search');
    await searchFor(tester, 'ada');

    await tester.tapAndSettle(tab('Feed'));
    await tester.tapAndSettle(tab('Search'));

    expect(tester.widget<TextField>(field).controller!.text, 'ada');
    expect(p1, findsOneWidget);
  });

  testWidgets('offline: the error, then "Try again" once back online', (
    tester,
  ) async {
    final container = await pumpConnectHub(tester, at: '/search');
    container.read(networkSimulatorProvider).failRequests = true;

    await searchFor(tester, 'ada');
    expect(find.text('Try again'), findsOneWidget);

    container.read(networkSimulatorProvider).failRequests = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(p1, findsOneWidget);
  });
}
