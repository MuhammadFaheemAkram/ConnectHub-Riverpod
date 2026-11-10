import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/core/navigation/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// The app's [GoRouter], as a provider.
///
/// - **Why a provider:** one router per container, so tests reach the same
///   instance through the container instead of a global. Routes that need
///   a provider (the redirect for my own profile reads the signed-in user's
///   id) reach the same container with `ProviderScope.containerOf`.
/// - **Why `keepAlive`:** generated providers are disposed as soon as nothing
///   listens to them. The router holds the navigation stack, so it must live
///   as long as the app does, even in a frame where no widget watches it.
/// - **Disposal:** `ref.onDispose` releases the router with its container,
///   so every test (its own `ProviderScope`) starts from a fresh one.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: const FeedRoute().location,
    routes: $appRoutes,
    errorBuilder: (context, state) =>
        _NotFoundPage(location: state.uri.toString()),
  );
  ref.onDispose(router.dispose);
  return router;
}

/// Shown when a location matches no route, e.g. a mistyped deep link.
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: EmptyStateView(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: 'Nothing lives at "$location".',
        action: FilledButton.tonal(
          onPressed: () => const FeedRoute().go(context),
          child: const Text('Go to the feed'),
        ),
      ),
    );
  }
}
