import 'package:connect_hub_riverpod/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/features/profile/profile_controller.dart';
import 'package:connect_hub_riverpod/features/profile/profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';

// ProfileController (a family by user id) and SavedPostsController, on the
// real provider graph in a container: the fake server, drift in memory.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late List<String> states;

  String describe(AsyncValue<ProfileState> value) => switch (value) {
    AsyncData(value: final profile) => [
      'data ${profile.user.name}',
      '[${profile.posts.map((post) => post.id).join(',')}]',
      if (profile.message case final message?) '"$message"',
    ].join(' '),
    AsyncValue(isLoading: true) => 'loading',
    AsyncError(:final error) => 'error ${error.runtimeType}',
    _ => 'loading',
  };

  void watchProfile(String userId) {
    states = [];
    container.listen(
      profileControllerProvider(userId),
      (_, next) => states.add(describe(next)),
      fireImmediately: true,
    );
  }

  setUp(() => container = testContainer());

  test('not cached: loading, then the profile and its posts', () async {
    watchProfile('u_ada');

    await container.read(profileControllerProvider('u_ada').future);
    await pumpEventQueue();

    expect(states.first, 'loading');
    expect(states.last, 'data Ada Lovelace [p1,p6,p11]');
  });

  test('cached: shown at once, then refreshed behind', () async {
    final profiles = container.read(profileRepositoryProvider);
    await profiles.refreshUser('u_ada');
    watchProfile('u_ada');

    await pumpEventQueue();

    expect(states[1], 'data Ada Lovelace []');
    expect(states.last, 'data Ada Lovelace [p1,p6,p11]');
  });

  test("an unknown user: NotFoundException (\"This profile isn't "
      'available.")', () async {
    watchProfile('u_nobody');

    await pumpEventQueue();

    expect(states.last, 'error NotFoundException');
  });

  test(
    'offline with nothing cached: an error, retried by "Try again"',
    () async {
      container = testContainer(
        overrides: realStack(
          network: NetworkSimulator(latencyFactor: 0, failRequests: true),
        ),
      );
      watchProfile('u_ada');
      await pumpEventQueue();
      expect(states.last, 'error NetworkException');

      container.read(networkSimulatorProvider).failRequests = false;
      container.invalidate(profileControllerProvider('u_ada'));
      await pumpEventQueue();

      expect(states.last, 'data Ada Lovelace [p1,p6,p11]');
    },
  );

  test(
    'a like on the profile is a like everywhere: the same drift row',
    () async {
      watchProfile('u_ada');
      final profile = await container.read(
        profileControllerProvider('u_ada').future,
      );

      await container
          .read(profileControllerProvider('u_ada').notifier)
          .toggleLike(profile.posts.first);
      await pumpEventQueue();

      final post = await container
          .read(postRepositoryProvider)
          .watchPost('p1')
          .first;
      expect(post?.isLiked, isTrue);
    },
  );

  test('Clear cache (the epoch) reloads the profile', () async {
    watchProfile('u_ada');
    await container.read(profileControllerProvider('u_ada').future);
    await pumpEventQueue();
    final before = states.length;

    container.read(cacheEpochProvider.notifier).cleared();
    await pumpEventQueue();

    expect(states.sublist(before), [
      'loading',
      'data Ada Lovelace [p1,p6,p11]',
    ]);
  });

  group('saved posts', () {
    Future<SavedPostsState> saved() async {
      await pumpEventQueue();
      return container.read(savedPostsControllerProvider).value!;
    }

    setUp(() async {
      container.listen(savedPostsControllerProvider, (_, _) {});
      await container.read(feedRepositoryProvider).refresh();
      await container
          .read(postRepositoryProvider)
          .setBookmarked('p2', bookmarked: true);
    });

    test('lists the saved posts, from the cache and then the server', () async {
      expect((await saved()).posts.map((post) => post.id), ['p2']);
    });

    test('unsaving removes it at once and offers Undo; Undo saves it '
        'again', () async {
      final controller = container.read(savedPostsControllerProvider.notifier);
      final p2 = (await saved()).posts.single;

      await controller.unsave(p2);
      final afterUnsave = await saved();
      expect(afterUnsave.posts, isEmpty);
      expect(afterUnsave.message, SavedPostsController.removedMessage);
      expect(afterUnsave.undoable?.id, 'p2');

      controller.messageShown();
      await controller.undo(p2);
      expect((await saved()).posts.map((post) => post.id), ['p2']);
    });

    test('an unsave the server refuses comes back, with no Undo', () async {
      final controller = container.read(savedPostsControllerProvider.notifier);
      final p2 = (await saved()).posts.single;
      container.read(networkSimulatorProvider).failRequests = true;

      await controller.unsave(p2);

      final state = await saved();
      expect(state.posts.map((post) => post.id), ['p2']);
      expect(state.message, SavedPostsController.saveFailedMessage);
      expect(state.undoable, isNull);
    });
  });

  test('a family: two profiles, two controllers', () async {
    container
      ..listen(profileControllerProvider('u_ada'), (_, _) {})
      ..listen(profileControllerProvider('u_grace'), (_, _) {});

    final ada = await container.read(profileControllerProvider('u_ada').future);
    final grace = await container.read(
      profileControllerProvider('u_grace').future,
    );

    expect(ada.user.name, 'Ada Lovelace');
    expect(grace.user.name, 'Grace Hopper');
  });
}
