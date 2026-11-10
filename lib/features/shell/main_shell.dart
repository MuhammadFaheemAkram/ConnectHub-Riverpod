import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Hosts the bottom [NavigationBar] around the active tab.
///
/// [navigationShell] holds the four tab navigators in an IndexedStack; this
/// widget only decides which branch is visible. Each tab screen brings its
/// own `Scaffold`, `AppBar` and actions. Phase 4 adds the unread badge on
/// Notifications, watched from a provider.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_none),
              selectedIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            NavigationDestination(
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
