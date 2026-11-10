import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/network/api/feed_api_service.dart';
import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/backend.dart';

// The service as the app builds it: through the network providers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  FeedApiService api() => container.read(feedApiServiceProvider);

  setUp(() => container = testContainer());

  test('answers as the signed-in demo user', () async {
    final liked = await api().setLiked('p1', liked: true);

    expect(liked.isLiked, isTrue);
    final server = container.read(fakeServerProvider);
    final asSeenByOther = await server.getFeed('u_other', limit: 1);
    expect(asSeenByOther.posts.single.isLiked, isFalse);
  });

  test('pages the feed in sixes by default', () async {
    final page = await api().getFeed();

    expect(page.posts, hasLength(6));
    expect(page.nextCursor, isNotNull);
  });

  test('fails through the simulated network', () async {
    container.read(networkSimulatorProvider).failRequests = true;

    await expectLater(api().getFeed(), throwsA(isA<NetworkException>()));
  });

  test('the app uses real latency; tests override it', () {
    final app = ProviderContainer.test();

    expect(app.read(networkSimulatorProvider).latencyFactor, 1);
    expect(container.read(networkSimulatorProvider).latencyFactor, 0);
  });
}
