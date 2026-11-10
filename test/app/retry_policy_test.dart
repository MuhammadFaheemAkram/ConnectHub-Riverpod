import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Why the app's ProviderScope passes `retry: noAutomaticRetry`: what a
// failing load looks like with and without Riverpod 3's default retry.
//
// The load fails with an `Exception`, as the app's services will (they throw
// `AppException`s). Riverpod's default never retries an `Error` (a bug in
// the code), only an `Exception` (something that might work next time).
void main() {
  late int builds;
  late FutureProvider<int> failingLoad;

  setUp(() {
    builds = 0;
    failingLoad = FutureProvider.autoDispose<int>((ref) async {
      builds++;
      throw const _ServerDown();
    });
  });

  test('noAutomaticRetry never schedules a retry', () {
    expect(noAutomaticRetry(0, Exception('offline')), isNull);
    expect(noAutomaticRetry(9, Exception('offline')), isNull);
  });

  test('without retry, a failed load is an AsyncError at once', () async {
    final container = ProviderContainer.test(retry: noAutomaticRetry);
    final states = <AsyncValue<int>>[];
    container.listen(failingLoad, (_, next) => states.add(next));

    await expectLater(
      container.read(failingLoad.future),
      throwsA(isA<_ServerDown>()),
    );

    expect(states.single, isA<AsyncError<int>>());
    expect(builds, 1);
  });

  test(
    "with Riverpod's default retry, the same failure keeps loading",
    () async {
      final container = ProviderContainer.test();
      final states = <AsyncValue<int>>[];
      container.listen(failingLoad, (_, next) => states.add(next));

      // Let the first build fail.
      await Future<void>.delayed(Duration.zero);

      // The UI would still show a spinner, not the error and "Try again":
      // Riverpod has scheduled a retry and reports loading meanwhile.
      expect(builds, 1);
      expect(states.single, isA<AsyncLoading<int>>());
      expect(states.single.error, isA<_ServerDown>());
    },
  );
}

class _ServerDown implements Exception {
  const _ServerDown();
}
