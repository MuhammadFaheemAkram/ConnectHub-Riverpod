import 'package:connect_hub_riverpod/core/common/clock_provider.dart';
import 'package:connect_hub_riverpod/core/common/id_generator.dart';
import 'package:connect_hub_riverpod/core/network/api/comment_api_service.dart';
import 'package:connect_hub_riverpod/core/network/api/fake_api_client.dart';
import 'package:connect_hub_riverpod/core/network/api/fake_comment_api_service.dart';
import 'package:connect_hub_riverpod/core/network/api/fake_feed_api_service.dart';
import 'package:connect_hub_riverpod/core/network/api/feed_api_service.dart';
import 'package:connect_hub_riverpod/core/network/asset_json_loader.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/seed_loader.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

// The fake backend, as providers. Everything here is `keepAlive`: the server
// holds the world's data (likes, saves) for the app's lifetime, and the
// simulator holds the "Simulate network failure" switch. An auto-dispose
// server would be re-seeded, and forget every like, whenever nothing happened
// to watch it.
//
// These providers are the only way into `core/network/`: repositories watch
// the `…ApiService` providers and never see the server, so a real HTTP
// client could replace the fakes by changing these few functions (or a
// test, by overriding them).

/// The bundle the seed JSON is read from.
@Riverpod(keepAlive: true)
AssetBundle assetBundle(Ref ref) => rootBundle;

/// The simulated network: latency and failures. Tests override it with
/// `NetworkSimulator(latencyFactor: 0)` for instant replies.
@Riverpod(keepAlive: true)
NetworkSimulator networkSimulator(Ref ref) => NetworkSimulator();

/// Ids for the posts and comments the server creates. Tests override it
/// with a seeded `Random` for repeatable ids.
@Riverpod(keepAlive: true)
IdGenerator idGenerator(Ref ref) => IdGenerator();

@Riverpod(keepAlive: true)
FakeServer fakeServer(Ref ref) => FakeServer(
  SeedLoader(AssetJsonLoader(ref.watch(assetBundleProvider))),
  ref.watch(idGeneratorProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
FakeApiClient fakeApiClient(Ref ref) => FakeApiClient(
  ref.watch(networkSimulatorProvider),
  ref.watch(fakeServerProvider),
);

/// Typed as the interface: what a repository depends on.
@Riverpod(keepAlive: true)
FeedApiService feedApiService(Ref ref) => FakeFeedApiService(
  ref.watch(fakeApiClientProvider),
  ref.watch(fakeServerProvider),
);

@Riverpod(keepAlive: true)
CommentApiService commentApiService(Ref ref) => FakeCommentApiService(
  ref.watch(fakeApiClientProvider),
  ref.watch(fakeServerProvider),
);
