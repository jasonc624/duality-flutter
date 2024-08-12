import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home.dart';
import '../profiles_feature/profile_list_widget.dart';
import '../profiles_feature/profiles_view.dart';
import '../relationships/relationships_list.dart';
import '../reports_feature/week_list.dart';
import '../settings/settings_view.dart';

class SideNavigation extends ConsumerWidget {
  final User? firebaseUser;

  const SideNavigation({super.key, required this.firebaseUser});
  Future<void> logout(context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context, rootNavigator: true).pop(context);
    } catch (e) {
      // print('Error during logout: $e');
      // TODO: Show an error message to the user
    }
  }

  Widget _getAvatarContent(User user) {
    if (user.photoURL != null) {
      return ClipOval(
        child: Image.network(
          user.photoURL!,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          errorBuilder: (context, error, stackTrace) {
            return _getInitials(user);
          },
        ),
      );
    } else {
      return _getInitials(user);
    }
  }

  Widget _getInitials(User? user) {
    final name = user?.displayName ?? user?.email ?? '';
    final dynamic initials =
        name.isNotEmpty ? name.substring(0, 2).toUpperCase() : 'JC';
    return Text(
      initials,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(0)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff3371FF),
                  Color(0xff8426D6),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'May your best side win today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                if (firebaseUser != null)
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.black,
                    child: _getAvatarContent(firebaseUser!),
                  ),
                const Expanded(
                  child: ProfileListWidget(),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.restorablePushNamed(context, MyHomePage.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_2_outlined),
            title: const Text('Profiles'),
            onTap: () {
              Navigator.restorablePushNamed(
                  context, ProfilesOverviewWidget.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.diversity_1_outlined),
            title: const Text('Relationships'),
            onTap: () {
              Navigator.restorablePushNamed(
                  context, RelationshipsPage.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: const Text('Reports'),
            onTap: () {
              Navigator.restorablePushNamed(context, WeeksList.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              await logout(context);
            },
          ),
        ],
      ),
    );
  }
}
