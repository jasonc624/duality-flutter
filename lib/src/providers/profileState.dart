import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'profileState.g.dart';

@riverpod
class ProfileState extends _$ProfileState {
  @override
  Map<String, dynamic> build() => {
        'selectedProfile': '',
        'profiles':
            <Map<String, dynamic>>[] // Initialize profiles as an empty list
      };
  String getCurrentProfile() => state['selectedProfile'] ?? 'default';

  void setProfile(String selectedProfileId) {
    state = {
      'selectedProfile': selectedProfileId,
      'profiles': state['profiles']
    };
    printState();
  }

  void setProfiles(List<Map<String, dynamic>> profiles) {
    state = {'selectedProfile': state['selectedProfile'], 'profiles': profiles};
    printState();
  }

  Future<void> getLastSelectedProfile(String userId) async {
    final DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      final data = userSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('last_selected_profile')) {
        final lastSelectedProfile = data['last_selected_profile'] as String?;
        if (lastSelectedProfile != null) {
          setProfile(lastSelectedProfile);
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getProfiles(String userId) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('profiles')
        .where('userRef', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final profiles = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      // Update the state with the fetched profiles
      setProfiles(profiles);

      return profiles;
    }

    return <Map<String, dynamic>>[];
  }

  void printState() {
    print('Current state: $state');
  }
}
