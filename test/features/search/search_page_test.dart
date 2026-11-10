import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/model/search_hits.dart';
import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_search_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

// The Search tab with the search repository replaced by a fake. Widget
// tests run in fake time, so the 300 ms debounce is pumped through.
void main() {
  const grace = User(id: 'u_grace', name: 'Grace Hopper', bio: 'COBOL');
  late FakeSearchRepository search;

  final field = find.byType(TextField);

  /// A section's title in the results (the chips have the same labels).
  Finder section(String title) =>
      find.descendant(of: find.byType(ListView), matching: find.text(title));

  Future<void> openSearch(WidgetTester tester) async {
    search =
        FakeSearchRepository(people: [ada, grace], posts: [samplePost('p1')])
          ..hitsFor['ada'] = const SearchHits(
            userIds: ['u_ada'],
            postIds: ['p1'],
          )
          ..hitsFor['grace'] = const SearchHits(userIds: ['u_grace']);
    addTearDown(search.dispose);
    await pumpConnectHub(
      tester,
      at: '/search',
      overrides: [
        ...realStack(),
        searchRepositoryProvider.overrideWithValue(search),
      ],
    );
  }

  Future<void> type(WidgetTester tester, String query) async {
    await tester.enterText(field, query);
    await tester.pump();
  }

  testWidgets('nothing typed and no history: the prompt', (tester) async {
    await openSearch(tester);

    expect(find.text('Search ConnectHub'), findsOneWidget);
    expect(find.text('Recent searches'), findsNothing);
  });

  testWidgets('typing: a spinner while it waits, then people and posts', (
    tester,
  ) async {
    await openSearch(tester);

    await type(tester, 'ada');
    expect(find.text('Searching…'), findsOneWidget);
    expect(search.searchCalls, isEmpty);

    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(search.searchCalls, ['ada']);
    expect(section('People'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsWidgets);
    expect(section('Posts'), findsOneWidget);
    expect(find.text('Post p1'), findsOneWidget);
  });

  testWidgets('a new query keeps the old results under a progress bar', (
    tester,
  ) async {
    await openSearch(tester);
    await type(tester, 'ada');
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await type(tester, 'grace');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.bySemanticsLabel('Searching'), findsOneWidget);
    expect(find.text('Post p1'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(find.text('Post p1'), findsNothing);
  });

  testWidgets('the scope chips filter what was found', (tester) async {
    await openSearch(tester);
    await type(tester, 'ada');
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await tester.tapAndSettle(find.widgetWithText(ChoiceChip, 'Posts'));
    expect(section('People'), findsNothing);
    expect(find.text('Post p1'), findsOneWidget);

    await tester.tapAndSettle(find.widgetWithText(ChoiceChip, 'People'));
    expect(find.text('Post p1'), findsNothing);
    expect(search.searchCalls, ['ada']);
  });

  testWidgets('no matches says so, for the scope', (tester) async {
    await openSearch(tester);

    await type(tester, 'zzz');
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text('No results'), findsOneWidget);
    expect(find.text('No people or posts match “zzz”.'), findsOneWidget);
  });

  testWidgets('a failure: the reason and "Try again"', (tester) async {
    await openSearch(tester);
    search.failure = const Err(NetworkException());

    await type(tester, 'ada');
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.text(const NetworkException().message), findsOneWidget);

    search.failure = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.text('Post p1'), findsOneWidget);
  });

  testWidgets('the search key saves a recent search; tapping it searches '
      'again; Clear history forgets them', (tester) async {
    await openSearch(tester);
    await type(tester, 'ada');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await tester.tapAndSettle(find.byTooltip('Clear search'));
    expect(find.text('Recent searches'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'ada'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.text('Post p1'), findsOneWidget);
    expect(tester.widget<TextField>(field).controller!.text, 'ada');

    await tester.tapAndSettle(find.byTooltip('Clear search'));
    await tester.tapAndSettle(find.text('Clear history'));
    expect(find.text('Search ConnectHub'), findsOneWidget);
  });

  testWidgets('opening a result saves the search and opens it', (tester) async {
    await openSearch(tester);
    await type(tester, 'grace');
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await tester.tapAndSettle(find.text('Grace Hopper'));

    expect(appBarTitled('Profile'), findsOneWidget);
    expect(search.recent, ['grace']);
  });
}
