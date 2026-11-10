import 'package:connect_hub_riverpod/core/navigation/app_router.dart';
import 'package:connect_hub_riverpod/core/navigation/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The router is the app's first `keepAlive` provider. These tests use no
// widgets: `ProviderContainer.test` is a container of its own, disposed
// automatically when the test ends.
void main() {
  test('starts on the Feed tab', () {
    final container = ProviderContainer.test();

    final router = container.read(appRouterProvider);

    expect(
      router.routeInformationProvider.value.uri.path,
      const FeedRoute().location,
    );
  });

  test('is kept alive: the same router even after nothing listens', () async {
    final container = ProviderContainer.test();
    final first = container.read(appRouterProvider);
    // For contrast: auto-dispose, the default of a generated provider.
    final screenState = Provider.autoDispose((ref) => Object());
    container.read(screenState);

    // An auto-dispose provider read without a listener is disposed once the
    // read is over; give that a chance to happen.
    await Future<void>.delayed(Duration.zero);

    expect(container.read(screenState.exists), isFalse);
    expect(container.read(appRouterProvider.exists), isTrue);
    expect(container.read(appRouterProvider), same(first));
  });

  test('is disposed with its container', () {
    final container = ProviderContainer.test();
    final router = container.read(appRouterProvider);

    container.dispose();

    // A disposed ChangeNotifier refuses new listeners (in debug builds).
    expect(
      () => router.routeInformationProvider.addListener(() {}),
      throwsA(isA<FlutterError>()),
    );
  });

  test('every container gets its own router', () {
    final a = ProviderContainer.test().read(appRouterProvider);
    final b = ProviderContainer.test().read(appRouterProvider);

    expect(a, isNot(same(b)));
  });
}
