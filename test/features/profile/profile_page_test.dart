import 'package:connect_hub_riverpod/core/navigation/app_router.dart';
import 'package:connect_hub_riverpod/features/profile/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/pump_app.dart';

// Profiles on the real stack. The demo user wrote p16 and p17.
void main() {
  final onProfile = appBarTitled('Profile');

  Finder tab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Finder inList(Finder target) =>
      find.descendant(of: find.byType(ListView), matching: target);

  // p1, Ada Lovelace's newest post.
  final p1 = find.textContaining('analytical engine scheduler');

  Finder onCard(Finder post, Finder target) => find.descendant(
    of: find.ancestor(of: post, matching: find.byType(Card)),
    matching: target,
  );

  group('my profile', () {
    testWidgets('the header with its counts, my posts, and the Settings '
        'gear', (tester) async {
      await pumpConnectHub(tester, at: '/profile');

      expect(find.text('Demo User'), findsWidgets);
      expect(find.bySemanticsLabel('128 Followers'), findsOneWidget);
      expect(find.bySemanticsLabel('2 Posts'), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Saved'), findsOneWidget);
    });

    testWidgets('Saved: empty at first; a post saved in the feed shows '
        'there', (tester) async {
      await pumpConnectHub(tester);
      await tester.tapAndSettle(onCard(p1, find.byTooltip('Save')));

      await tester.tapAndSettle(tab('Profile'));
      await tester.tapAndSettle(find.widgetWithText(Tab, 'Saved'));

      expect(p1, findsOneWidget);
    });

    testWidgets('unsaving says "Removed from saved", and Undo puts it back', (
      tester,
    ) async {
      await pumpConnectHub(tester);
      await tester.tapAndSettle(onCard(p1, find.byTooltip('Save')));
      await tester.tapAndSettle(tab('Profile'));
      await tester.tapAndSettle(find.widgetWithText(Tab, 'Saved'));

      // Below the header, the card's buttons start off the phone's screen
      // (a tap there would miss silently, conventions §11.51).
      await tester.ensureVisible(onCard(p1, find.byTooltip('Unsave')));
      await tester.pumpAndSettle();
      await tester.tap(onCard(p1, find.byTooltip('Unsave')));
      await tester.pumpAndSettle();
      expect(find.text(SavedPostsController.removedMessage), findsOneWidget);
      expect(inList(p1), findsNothing);

      await tester.tapAndSettle(find.text('Undo'));
      expect(inList(p1), findsOneWidget);
    });
  });

  group("someone else's profile", () {
    testWidgets('from an author on the feed: their header and posts, '
        'pushed over the tabs', (tester) async {
      await pumpConnectHub(tester);

      await tester.tapAndSettle(onCard(p1, find.text('Ada Lovelace')));

      expect(onProfile, findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Enchantress of numbers.'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Saved'), findsNothing);
      expect(find.byTooltip('Settings'), findsNothing);
    });

    testWidgets("an unknown user: \"This profile isn't available.\"", (
      tester,
    ) async {
      await pumpConnectHub(tester, at: '/users/u_nobody');

      expect(find.text("This profile isn't available."), findsOneWidget);
    });
  });

  group('my own id', () {
    testWidgets('a link to /users/<me> lands on the Profile tab', (
      tester,
    ) async {
      await pumpConnectHub(tester, at: '/users/u_demo');

      expect(tester.selectedTab, 3);
      expect(find.widgetWithText(Tab, 'Saved'), findsOneWidget);
    });

    testWidgets('tapping my own name on my post switches to the tab: '
        'nothing pushed, and the post is not left underneath', (tester) async {
      final container = await pumpConnectHub(tester, at: '/posts/p16');

      await tester.tapAndSettle(find.text('Demo User').first);

      expect(tester.selectedTab, 3);
      expect(container.read(appRouterProvider).canPop(), isFalse);
    });
  });
}
