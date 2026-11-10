import 'package:connect_hub_riverpod/core/common/session_providers.dart';
import 'package:connect_hub_riverpod/features/profile/profile_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The Profile tab: the signed-in user's own profile.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ProfileView(userId: ref.watch(signedInUserIdProvider), isMine: true);
}
