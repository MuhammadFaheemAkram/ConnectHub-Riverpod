import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';
import '../helpers/backend.dart';
import '../helpers/fakes/fake_comment_repository.dart';
import '../helpers/fakes/fake_feed_repository.dart';
import '../helpers/fakes/fake_post_repository.dart';
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
        ('Post Detail', '/posts/p1'),
        ('Post Detail, no longer available', '/posts/p999'),
        ('Create Post', '/compose'),
        ("Someone's profile", '/users/u_ada'),
        ("A profile that isn't available", '/users/u_nobody'),
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

      testWidgets('Post Detail, with my comment and a liked one', (
        tester,
      ) async {
        final posts = FakePostRepository(
          cached: samplePost('p1', commentCount: 2, isLiked: true),
        );
        final comments = FakeCommentRepository(
          cached: [
            sampleComment('c1', isLiked: true, likeCount: 12),
            sampleComment('c2', isMine: true),
          ],
        );
        addTearDown(posts.dispose);
        addTearDown(comments.dispose);
        await open(
          tester,
          '/posts/p1',
          overrides: [
            ...realStack(),
            postRepositoryProvider.overrideWithValue(posts),
            commentRepositoryProvider.overrideWithValue(comments),
          ],
        );
        expect(find.text('You'), findsOneWidget);

        await expectAccessible(tester);
      });

      testWidgets('Create Post, with errors', (tester) async {
        await open(tester, '/compose');
        await tester.enterText(
          find.widgetWithText(TextField, "What's on your mind?"),
          'a' * 300,
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Image URL (optional)'),
          'not a url',
        );
        await tester.pumpAndSettle();
        expect(find.text('Enter a valid image URL.'), findsOneWidget);

        await expectAccessible(tester);
      });

      testWidgets('Create Post, "Discard post?"', (tester) async {
        await open(tester, '/compose');
        await tester.enterText(
          find.widgetWithText(TextField, "What's on your mind?"),
          'Draft',
        );
        await tester.pump();
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
        expect(find.text('Discard post?'), findsOneWidget);

        await expectAccessible(tester);
      });

      testWidgets('Search, with results and a recent search', (tester) async {
        await open(tester, '/search');
        await tester.enterText(find.byType(TextField), 'ada');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        expect(find.text('Ada Lovelace'), findsWidgets);

        await expectAccessible(tester);

        await tester.tap(find.byTooltip('Clear search'));
        await tester.pumpAndSettle();
        expect(find.text('Recent searches'), findsOneWidget);

        await expectAccessible(tester);
      });

      testWidgets('Search, no results', (tester) async {
        await open(tester, '/search');
        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        expect(find.text('No results'), findsOneWidget);

        await expectAccessible(tester);
      });

      testWidgets('Notifications, unread only, then nothing unread', (
        tester,
      ) async {
        await open(tester, '/notifications');
        await tester.tap(find.widgetWithText(FilterChip, 'Unread'));
        await tester.pumpAndSettle();

        await expectAccessible(tester);

        await tester.tap(find.text('Mark all read'));
        await tester.pumpAndSettle();
        expect(find.text('Nothing unread.'), findsOneWidget);

        await expectAccessible(tester);
      });

      testWidgets('Profile, my saved posts', (tester) async {
        await open(tester, '/feed');
        await tester.tap(find.byTooltip('Save').first);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Profile'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(Tab, 'Saved'));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Unsave'), findsOneWidget);

        await expectAccessible(tester);
      });

      testWidgets('Settings, "Clear cache?"', (tester) async {
        await open(tester, '/settings');
        await tester.tap(find.text('Clear cache'));
        await tester.pumpAndSettle();
        expect(find.text('Clear cache?'), findsOneWidget);

        await expectAccessible(tester);
      });
    });
  }
}
