import 'package:connect_hub_riverpod/core/common/debounce.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> ran;

  // A family that waits 300 ms, then records its argument.
  late FutureProvider<String> Function(String) debounced;

  setUp(() {
    ran = [];
    final family = FutureProvider.autoDispose.family<String, String>((
      ref,
      query,
    ) async {
      await ref.debounce(const Duration(milliseconds: 300));
      ran.add(query);
      return query;
    });
    debounced = family.call;
  });

  test('the work runs once the delay is over', () {
    fakeAsync((async) {
      final container = ProviderContainer.test();
      container.listen(debounced('ada'), (_, _) {});

      async.elapse(const Duration(milliseconds: 299));
      expect(ran, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      expect(ran, ['ada']);
    });
  });

  test('disposed first: the work never runs, and no timer is left', () {
    fakeAsync((async) {
      final container = ProviderContainer.test();
      final listening = container.listen(debounced('ada'), (_, _) {});
      async.elapse(const Duration(milliseconds: 100));

      listening.close();
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 1));

      expect(ran, isEmpty);
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('a wait cancelled by disposal never resumes, and raises no '
      'error', () {
    fakeAsync((async) {
      final container = ProviderContainer.test();
      final listening = container.listen(debounced('a'), (_, _) {});
      listening.close();
      container.listen(debounced('ada'), (_, _) {});

      async.elapse(const Duration(seconds: 1));

      // Only the provider still listened to got past its wait. (An error
      // raised by the cancelled one would fail this test as uncaught.)
      expect(ran, ['ada']);
    });
  });
}
