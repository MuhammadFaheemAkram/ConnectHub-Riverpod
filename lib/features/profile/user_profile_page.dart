import 'package:connect_hub_riverpod/features/profile/profile_view.dart';
import 'package:material_ui/material_ui.dart';

/// Someone else's profile, pushed over the tabs. (My own id never gets here:
/// `UserProfileRoute` redirects it to the Profile tab.)
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) =>
      ProfileView(userId: userId, isMine: false);
}
