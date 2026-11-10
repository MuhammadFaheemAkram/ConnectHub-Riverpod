import 'package:connect_hub_riverpod/core/common/validators.dart';
import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  group('CommentTile', () {
    testWidgets('shows the author, the time, the text and its likes', (
      tester,
    ) async {
      await tester.pumpThemed(
        CommentTile(comment: sampleComment('c1', minutesAgo: 5, likeCount: 4)),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('5m'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.byTooltip('Like comment'), findsOneWidget);
      expect(find.text('Comment c1'), findsOneWidget);
      expect(find.byTooltip('Comment options'), findsNothing);
    });

    testWidgets('my own comment says "You" and offers Delete', (tester) async {
      var deletes = 0;
      await tester.pumpThemed(
        CommentTile(
          comment: sampleComment('c1', isMine: true),
          onDelete: () => deletes++,
        ),
      );

      expect(find.text('You'), findsOneWidget);
      await tester.tap(find.byTooltip('Comment options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deletes, 1);
    });
  });

  group('CommentTile likes', () {
    testWidgets('a liked comment says so, and a tap reaches onLike', (
      tester,
    ) async {
      var likes = 0;
      await tester.pumpThemed(
        CommentTile(
          comment: sampleComment('c1', isLiked: true, likeCount: 5),
          onLike: () => likes++,
        ),
      );

      await tester.tap(find.byTooltip('Unlike comment'));

      expect(likes, 1);
    });
  });

  group('ComposerBar', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    IconButton send(WidgetTester tester) => tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Send'),
        matching: find.byType(IconButton),
      ),
    );

    testWidgets('Send waits for non-blank text, then sends it', (tester) async {
      final sent = <String>[];
      await tester.pumpThemed(
        ComposerBar(controller: controller, onSend: sent.add),
      );
      expect(send(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '  ');
      await tester.pump();
      expect(send(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Nice!');
      await tester.pump();
      await tester.tap(find.byTooltip('Send'));

      expect(sent, ['Nice!']);
    });

    testWidgets('while sending: progress, and the text can\'t change', (
      tester,
    ) async {
      controller.text = 'Nice!';
      await tester.pumpThemed(
        ComposerBar(controller: controller, isSending: true, onSend: (_) {}),
      );

      expect(find.bySemanticsLabel('Sending'), findsOneWidget);
      expect(send(tester).onPressed, isNull);
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    });

    testWidgets('the field enforces its limit: 500 for a comment', (
      tester,
    ) async {
      await tester.pumpThemed(
        ComposerBar(controller: controller, onSend: (_) {}),
      );
      await tester.enterText(find.byType(TextField), 'a' * 600);

      expect(controller.text, hasLength(Validators.commentMaxLength));
    });
  });

  group('CharacterCounter', () {
    Color? colorOf(WidgetTester tester, String text) =>
        tester.widget<Text>(find.text(text)).style?.color;

    testWidgets('turns to the error color once over the limit', (tester) async {
      final scheme = AppTheme.light().colorScheme;

      await tester.pumpThemed(const CharacterCounter(count: 280, max: 280));
      expect(colorOf(tester, '280/280'), scheme.onSurfaceVariant);

      await tester.pumpThemed(const CharacterCounter(count: 281, max: 280));
      expect(colorOf(tester, '281/280'), scheme.error);
      expect(find.bySemanticsLabel('281 of 280 characters'), findsOneWidget);
    });
  });
}
