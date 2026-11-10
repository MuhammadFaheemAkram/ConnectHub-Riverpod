import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('LoadingView', () {
    testWidgets('shows a spinner and its message', (tester) async {
      await tester.pumpThemed(const LoadingView(message: 'Loading your feed…'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading your feed…'), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('shows the message without a retry button by default', (
      tester,
    ) async {
      await tester.pumpThemed(const ErrorView(message: 'Network down.'));

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Network down.'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('calls onRetry when "Try again" is tapped', (tester) async {
      var retries = 0;
      await tester.pumpThemed(
        ErrorView(message: 'Network down.', onRetry: () => retries++),
      );

      await tester.tap(find.text('Try again'));

      expect(retries, 1);
    });
  });

  group('EmptyStateView', () {
    testWidgets('renders its icon, title, message and action', (tester) async {
      var taps = 0;
      await tester.pumpThemed(
        EmptyStateView(
          icon: Icons.dynamic_feed_outlined,
          title: 'No posts yet',
          message: 'Be the first to share something.',
          action: TextButton(
            onPressed: () => taps++,
            child: const Text('New post'),
          ),
        ),
      );

      expect(find.byIcon(Icons.dynamic_feed_outlined), findsOneWidget);
      expect(find.text('No posts yet'), findsOneWidget);
      expect(find.text('Be the first to share something.'), findsOneWidget);
      await tester.tap(find.text('New post'));
      expect(taps, 1);
    });

    testWidgets('omits the message and action when not provided', (
      tester,
    ) async {
      await tester.pumpThemed(
        const EmptyStateView(icon: Icons.search, title: 'Search ConnectHub'),
      );

      expect(find.text('Search ConnectHub'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });
  });
}
