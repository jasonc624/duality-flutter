import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ads/list_ad.dart';
import '../behavior_entry_feature/behavior_list.dart';
import '../behavior_entry_feature/behavior_list_charts.dart';
import '../behavior_entry_feature/create_update_behavior.dart';
import '../login_page/login_page.dart';
import '../navigation_drawer/side_navigation.dart';
import 'timeline/bg_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Riverpod;
import '../providers/speechState.dart';
import '../providers/profileState.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});
  static const list_ad_unit_id = 'ca-app-pub-7953505687288854/2493891961';
  static const routeName = '/home';
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(textToSpeechProvider.notifier);
      ref.read(profilesProvider.notifier).loadAllProfiles();
    });
  }

  BannerAd? _bannerAd;

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      setState(() {});
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ));
    } catch (e) {
      // print('Error during logout: $e');
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
        title: const Text('Polarity'),
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
            BehaviorAnalysisPieCharts(userRef: currentUserUid),
            const SizedBox(height: 8.0),
            const SafeArea(
              child: ListAdWidget(
                adUnitId: 'test',
                adSize: AdSize.banner,
              ),
            ),
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
