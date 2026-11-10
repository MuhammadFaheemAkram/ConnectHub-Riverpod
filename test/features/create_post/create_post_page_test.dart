import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_post_repository.dart';
import '../../helpers/pump_app.dart';

// The New post form, opened from the Feed's button, with the post
// repository replaced by a fake.
void main() {
  late FakePostRepository posts;

  final text = find.widgetWithText(TextField, "What's on your mind?");
  final imageUrl = find.widgetWithText(TextField, 'Image URL (optional)');
  final onComposer = appBarTitled('New post');
  final onFeed = appBarTitled('ConnectHub');

  Future<void> openComposer(WidgetTester tester) async {
    posts = FakePostRepository();
    addTearDown(posts.dispose);
    await pumpConnectHub(
      tester,
      overrides: [
        ...realStack(),
        postRepositoryProvider.overrideWithValue(posts),
      ],
    );
    await tester.tapAndSettle(find.byTooltip('New post'));
  }

  FilledButton post(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Post'));

  testWidgets('opens empty, with Post disabled and the counter at 0', (
    tester,
  ) async {
    await openComposer(tester);

    expect(onComposer, findsOneWidget);
    expect(find.text('0/280'), findsOneWidget);
    expect(post(tester).onPressed, isNull);
  });

  testWidgets('the counter and the errors follow the input', (tester) async {
    await openComposer(tester);

    await tester.enterText(text, 'a' * 281);
    await tester.pump();
    expect(find.text('281/280'), findsOneWidget);
    expect(find.text('Posts can be at most 280 characters.'), findsOneWidget);

    await tester.enterText(text, 'Hello');
    await tester.enterText(imageUrl, 'not a url');
    await tester.pump();
    expect(find.text('Enter a valid image URL.'), findsOneWidget);
    expect(post(tester).onPressed, isNull);
  });

  testWidgets('posting shows progress, then closes', (tester) async {
    await openComposer(tester);
    posts.createGate = Completer<void>();

    await tester.enterText(text, 'Hello, ConnectHub!');
    await tester.pump();
    await tester.tap(find.text('Post'));
    await tester.pump();
    expect(find.bySemanticsLabel('Posting'), findsOneWidget);

    posts.createGate!.complete();
    await tester.pumpAndSettle();

    expect(posts.createCalls, [
      (content: 'Hello, ConnectHub!', imageUrl: null),
    ]);
    expect(onFeed, findsOneWidget);
  });

  testWidgets('a failure keeps the text and shows why', (tester) async {
    await openComposer(tester);
    posts.createResult = const Err(NetworkException());

    await tester.enterText(text, 'Hello');
    await tester.pump();
    await tester.tapAndSettle(find.text('Post'));

    expect(onComposer, findsOneWidget);
    expect(find.text(const NetworkException().message), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('leaving with a draft asks "Discard post?"', (tester) async {
    await openComposer(tester);
    await tester.enterText(text, 'Half a thought');
    await tester.pump();

    await tester.tapAndSettle(find.byTooltip('Close'));
    expect(find.text('Discard post?'), findsOneWidget);

    await tester.tapAndSettle(find.text('Cancel'));
    expect(onComposer, findsOneWidget);

    await tester.tapAndSettle(find.byTooltip('Close'));
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Discard'));
    expect(onFeed, findsOneWidget);
    expect(posts.createCalls, isEmpty);
  });

  testWidgets("the system back gesture asks too (the page's PopScope)", (
    tester,
  ) async {
    await openComposer(tester);
    await tester.enterText(text, 'Half a thought');
    await tester.pump();

    // What Android's back button or iOS's edge swipe sends.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard post?'), findsOneWidget);
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Discard'));
    expect(onFeed, findsOneWidget);
  });

  testWidgets('leaving with nothing written just closes', (tester) async {
    await openComposer(tester);

    await tester.tapAndSettle(find.byTooltip('Close'));

    expect(find.text('Discard post?'), findsNothing);
    expect(onFeed, findsOneWidget);
  });

  testWidgets('opened by a link: Close still asks about a draft, then goes '
      'to the feed', (tester) async {
    posts = FakePostRepository();
    addTearDown(posts.dispose);
    await pumpConnectHub(
      tester,
      at: '/compose',
      overrides: [
        ...realStack(),
        postRepositoryProvider.overrideWithValue(posts),
      ],
    );
    await tester.enterText(text, 'Draft');
    await tester.pump();

    await tester.tapAndSettle(find.byTooltip('Close'));
    expect(find.text('Discard post?'), findsOneWidget);
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Discard'));

    expect(onFeed, findsOneWidget);
  });
}
