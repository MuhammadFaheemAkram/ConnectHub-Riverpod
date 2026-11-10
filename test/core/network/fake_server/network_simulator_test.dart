import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('waits for the latency, scaled by the factor', () {
    fakeAsync((async) {
      var done = false;
      NetworkSimulator(latencyFactor: 2)
          .run(const Duration(milliseconds: 300))
          .then((_) => done = true);

      async.elapse(const Duration(milliseconds: 599));
      expect(done, isFalse);
      async.elapse(const Duration(milliseconds: 1));
      expect(done, isTrue);
    });
  });

  test('a factor of 0 answers at once, without a timer', () {
    fakeAsync((async) {
      var done = false;
      NetworkSimulator(latencyFactor: 0)
          .run(const Duration(seconds: 1))
          .then((_) => done = true);

      async.flushMicrotasks();
      expect(done, isTrue);
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('fails every request while failRequests is on, and recovers', () async {
    final network = NetworkSimulator(latencyFactor: 0, failRequests: true);

    await expectLater(
      network.run(Duration.zero),
      throwsA(isA<NetworkException>()),
    );

    network.failRequests = false;
    await expectLater(network.run(Duration.zero), completes);
  });
}
