import 'package:duality/src/behavior_entry_feature/behavior_list.dart';
import 'package:duality/src/login_page/login_page.dart';
import 'package:duality/src/navigation_drawer/side_navigation.dart';

import 'package:flutter/material.dart';
import '../behavior_entry_feature/create_update_behavior.dart';

import '../providers/profileState.dart';
import 'timeline/bg_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Riverpod;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  static const routeName = '/home';
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profilesProvider.notifier).loadAllProfiles();
    });
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Optional: Navigate to login screen or show a success message
      // print('User logged out successfully');
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ));
      setState(() {});
    } catch (e) {
      // print('Error during logout: $e');
      // Optional: Show an error message to the user
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

  void _createBehavior(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateUpdateBehavior(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    String currentUserUid = firebaseUser?.uid ?? '';
    // Get profiles for the current user

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Polarity'),
      ),
      drawer: SideNavigation(
        firebaseUser: firebaseUser,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            const CustomBackgroundExample(),
            const SizedBox(height: 16.0),
            BehaviorListView(userRef: currentUserUid),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createBehavior(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
