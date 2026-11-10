import 'package:connect_hub_riverpod/core/design_system/design_system.dart';
import 'package:connect_hub_riverpod/features/notifications/notifications_controller.dart';
import 'package:connect_hub_riverpod/features/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Hosts the bottom [NavigationBar] around the active tab.
///
/// [navigationShell] holds the four tab navigators in an IndexedStack; this
/// widget only decides which branch is visible. Each tab screen brings its
/// own `Scaffold`, `AppBar` and actions.
///
/// It also owns the Notifications badge: it watches the unread count, and
/// *listens* to the notifications controller from launch, which keeps it
/// alive (and loaded) for as long as the shell is there, before the tab is
/// ever opened.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A listener with nothing to do: its only job is to keep the controller
    // alive, so the first load runs now and the badge is right.
    ref.listen(notificationsControllerProvider, (_, _) {});
    // Settings → "Show unread badge": off, the count is hidden (and not
    // even watched).
    final showBadge = ref.watch(
      settingsControllerProvider.select((settings) => settings.showUnreadBadge),
    );
    final unread = showBadge
        ? ref.watch(unreadNotificationCountProvider).value ?? 0
        : 0;
    return Scaffold(
      body: navigationShell,
      // The tab labels keep their size whatever the text setting, as on iOS's
      // own tab bar: four labels share the width, and "Notifications" would
      // break mid-word at large sizes. A long press shows the label in a
      // tooltip, and screen readers read it.
      bottomNavigationBar: MediaQuery.withNoTextScaling(
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          // Order must match the branches declared in `app_routes.dart`.
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Feed',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: UnreadBadge(
                count: unread,
                child: const Icon(Icons.notifications_none),
              ),
              selectedIcon: UnreadBadge(
                count: unread,
                child: const Icon(Icons.notifications),
              ),
              label: 'Notifications',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    // Re-tapping the active tab returns it to its initial location (the
    // platform convention on both Android and iOS).
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
