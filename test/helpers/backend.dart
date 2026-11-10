import 'dart:math';

import 'package:clock/clock.dart';
import 'package:connect_hub_riverpod/app/retry_policy.dart';
import 'package:connect_hub_riverpod/core/common/clock_provider.dart';
import 'package:connect_hub_riverpod/core/common/id_generator.dart';
import 'package:connect_hub_riverpod/core/database/app_database.dart';
import 'package:connect_hub_riverpod/core/network/asset_json_loader.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/fake_server.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/seed_loader.dart';
import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// The moment every test's fake server launches at.
final testNow = DateTime.utc(2026, 10, 11, 12);

/// The real in-memory fake server, seeded from the bundled JSON, with
/// repeatable ids and a fixed clock. Needs
/// `TestWidgetsFlutterBinding.ensureInitialized()` for the asset bundle.
FakeServer newFakeServer({Clock? clock}) => FakeServer(
  SeedLoader(AssetJsonLoader(rootBundle)),
  IdGenerator(random: Random(1)),
  clock ?? Clock.fixed(testNow),
);

/// A fresh in-memory database: no disk, no state shared between tests, for
/// tests that use a database without a container. Close it in `tearDown`.
AppDatabase newTestDatabase() => AppDatabase(newTestConnection());

/// An in-memory SQLite connection. Its streams close synchronously, so a
/// widget test doesn't end with drift's stream-cleanup timer still pending
/// (conventions §11.24).
DatabaseConnection newTestConnection() => DatabaseConnection(
  NativeDatabase.memory(),
  closeStreamsSynchronously: true,
);

/// The app's real provider graph, made deterministic: a fixed clock,
/// repeatable ids, a network with no latency, an in-memory database. Everything else (the
/// fake server, the services, the repositories, the use cases) is the real
/// thing.
///
/// This replaces ConnectHub-Flutter's `test_dependencies.dart`, which
/// re-registered fakes in get_it before each test and reset it after. Here,
/// overrides belong to one container: nothing global, nothing to reset.
///
/// [database] replaces the fresh one, e.g. a database that already holds a
/// cache "from the last launch"; its test closes it.
List<Override> realStack({
  Clock? clock,
  NetworkSimulator? network,
  AppDatabase? database,
}) => [
  clockProvider.overrideWithValue(clock ?? Clock.fixed(testNow)),
  idGeneratorProvider.overrideWithValue(IdGenerator(random: Random(1))),
  networkSimulatorProvider.overrideWithValue(
    network ?? NetworkSimulator(latencyFactor: 0),
  ),
  if (database != null)
    appDatabaseProvider.overrideWithValue(database)
  else
    // Only the connection is swapped: the app's own database provider still
    // builds the database, and closes it with the container.
    databaseConnectionProvider.overrideWith((ref) => newTestConnection()),
];

/// A container for tests without widgets, configured as the app's scope is
/// (no automatic retry), and disposed when the test ends.
ProviderContainer testContainer({List<Override>? overrides}) =>
    ProviderContainer.test(
      retry: noAutomaticRetry,
      overrides: overrides ?? realStack(),
    );
