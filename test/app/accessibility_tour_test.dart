import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';
import '../helpers/backend.dart';
import '../helpers/fakes/fake_feed_repository.dart';
import '../helpers/fixtures.dart';

// Every screen and state, in light and dark, with text at 200%: no layout
// overflows (an overflow fails the test), tap targets of at least 48 × 48, a
// label on everything tappable, and readable text. Each phase adds its
// screens and states here.
void main() {
  for (final brightness in Brightness.values) {
    group('${brightness.name} theme, text at 200%', () {
      Future<void> open(
        WidgetTester tester,
        String location, {
        List<Override>? overrides,
      }) async {
        tester.platformDispatcher
          ..textScaleFactorTestValue = 2
          ..platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await pumpConnectHub(tester, at: location, overrides: overrides);
        // Phone width, but tall enough to lay out every item of a long list:
        // the checks below see only what is built.
        tester.view.physicalSize = const Size(390 * 3, 6000 * 3);
        await tester.pumpAndSettle();
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

      /// The real stack, with the feed's repository replaced by [feed].
      List<Override> withFeed(FakeFeedRepository feed) {
        addTearDown(feed.dispose);
        return [...realStack(), feedRepositoryProvider.overrideWithValue(feed)];
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

      testWidgets('Feed, empty', (tester) async {
        await open(
          tester,
          '/feed',
          overrides: withFeed(FakeFeedRepository()..refreshedWindow = []),
        );
        expect(find.text('No posts yet'), findsOneWidget);

        await expectAccessible(tester);
      });

      testWidgets("Feed, couldn't load", (tester) async {
        await open(
          tester,
          '/feed',
          overrides: realStack(
            network: NetworkSimulator(latencyFactor: 0, failRequests: true),
          ),
        );
        expect(find.text('Try again'), findsOneWidget);

        await expectAccessible(tester);
      });

      testWidgets("Feed, a page that couldn't load", (tester) async {
        await open(
          tester,
          '/feed',
          overrides: withFeed(
            FakeFeedRepository(
              cached: [samplePost('p1', isLiked: true, isBookmarked: true)],
            )..loadMoreResult = const Err(NetworkException()),
          ),
        );
        expect(find.text('Retry'), findsOneWidget);

        await expectAccessible(tester);
      });
    });
  }
}
