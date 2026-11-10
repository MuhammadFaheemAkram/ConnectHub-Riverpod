import 'package:connect_hub_riverpod/core/common/session_providers.dart';
import 'package:connect_hub_riverpod/features/create_post/create_post_page.dart';
import 'package:connect_hub_riverpod/features/feed/feed_page.dart';
import 'package:connect_hub_riverpod/features/notifications/notifications_page.dart';
import 'package:connect_hub_riverpod/features/post_detail/post_detail_page.dart';
import 'package:connect_hub_riverpod/features/profile/profile_page.dart';
import 'package:connect_hub_riverpod/features/profile/user_profile_page.dart';
import 'package:connect_hub_riverpod/features/search/search_page.dart';
import 'package:connect_hub_riverpod/features/settings/settings_page.dart';
import 'package:connect_hub_riverpod/features/shell/main_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

part 'app_routes.g.dart';

// Typed routes: every destination is a class, and `go_router_builder`
// generates its path parsing, `location` getter and `go`/`push` helpers. A
// typo or a missing parameter is a compile error instead of a runtime "page
// not found".
//
// The tree has two parts:
// 1. the tab shell, one branch per tab;
// 2. root-level screens, pushed *above* the shell: a post, someone's
//    profile, the composer, Settings.
//
// No sign-in gate: the demo user is always signed in (auth is out of scope).

// ---------------------------------------------------------------------------
// 1. The tab shell

/// `StatefulShellRoute` gives every tab its own Navigator and keeps inactive
/// tabs alive in an IndexedStack, so switching tabs preserves each tab's
/// state (scroll position, search query).
@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<FeedBranch>(
      routes: [TypedGoRoute<FeedRoute>(path: '/feed')],
    ),
    TypedStatefulShellBranch<SearchBranch>(
      routes: [TypedGoRoute<SearchRoute>(path: '/search')],
    ),
    TypedStatefulShellBranch<NotificationsBranch>(
      routes: [TypedGoRoute<NotificationsRoute>(path: '/notifications')],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [TypedGoRoute<ProfileRoute>(path: '/profile')],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainShell(navigationShell: navigationShell);
  }
}

// A named navigator key per tab makes each back stack addressable (and
// readable in debugging tools).

class FeedBranch extends StatefulShellBranchData {
  const FeedBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'feedTab');
}

class SearchBranch extends StatefulShellBranchData {
  const SearchBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'searchTab');
}

class NotificationsBranch extends StatefulShellBranchData {
  const NotificationsBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'notificationsTab');
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profileTab');
}

class FeedRoute extends GoRouteData with $FeedRoute {
  const FeedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const FeedPage();
}

class SearchRoute extends GoRouteData with $SearchRoute {
  const SearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SearchPage();
}

class NotificationsRoute extends GoRouteData with $NotificationsRoute {
  const NotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NotificationsPage();
}

/// The signed-in user's own profile.
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfilePage();
}

// ---------------------------------------------------------------------------
// 2. Root-level screens
//
// Declared at the top level, so they live in the *root* Navigator: pushing
// one from a tab covers the tab bar, and Back returns to that tab with its
// state intact.

/// `/posts/:postId`: reachable from every tab (the feed now; search and
/// profiles later), so one root-level route beats a copy per tab.
@TypedGoRoute<PostDetailRoute>(path: '/posts/:postId')
class PostDetailRoute extends GoRouteData with $PostDetailRoute {
  const PostDetailRoute({required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PostDetailPage(postId: postId);
}

/// `/users/:userId`: someone else's profile. Open it with [openProfile].
@TypedGoRoute<UserProfileRoute>(path: '/users/:userId')
class UserProfileRoute extends GoRouteData with $UserProfileRoute {
  const UserProfileRoute({required this.userId});

  final String userId;

  /// My own id goes to the Profile tab (a deep link, say): one "me" screen,
  /// the one with Saved and the Settings gear.
  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      _isMe(context, userId) ? const ProfileRoute().location : null;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      UserProfilePage(userId: userId);
}

/// Opens [userId]'s profile from any screen.
///
/// Someone else's profile is pushed above the tabs. Mine is the Profile tab,
/// so the app switches to it (`go`) instead: pushing a location that
/// redirects into a tab of the shell would put a second shell on the stack,
/// which the Navigator rejects (conventions §11.30).
void openProfile(BuildContext context, String userId) {
  if (_isMe(context, userId)) {
    const ProfileRoute().go(context);
  } else {
    UserProfileRoute(userId: userId).push<void>(context);
  }
}

/// Whether [userId] is the signed-in user. A route is no widget, so it
/// reaches the provider through the `ProviderScope` above the router.
bool _isMe(BuildContext context, String userId) =>
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(signedInUserIdProvider) ==
    userId;

/// `/compose`: a full-screen dialog (a close button instead of Back, and it
/// slides up), the Material counterpart of an iOS sheet.
@TypedGoRoute<CreatePostRoute>(path: '/compose')
class CreatePostRoute extends GoRouteData with $CreatePostRoute {
  const CreatePostRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(
        key: state.pageKey,
        fullscreenDialog: true,
        child: const CreatePostPage(),
      );
}

/// `/settings`, opened from the Profile tab's gear.
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}
