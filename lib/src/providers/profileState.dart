import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profiles_feature/repository_profile.dart';

class Profile {
  Profile({
    required this.created,
    required this.id,
    required this.isDefault,
    required this.name,
    required this.userRef,
  });
  final DateTime created;
  final String? id;
  final bool isDefault;
  final String name;
  final String userRef;

  // Factory constructor to create a Profile from a Firebase document
  factory Profile.fromFirebase(DocumentSnapshot map, String documentId) {
    final data = map.data() as Map<String, dynamic>;
    return Profile(
      created: (data['created'] as Timestamp).toDate(),
      id: map.id,
      isDefault: data['isDefault'] ?? false,
      name: data['name'],
      userRef: data['userRef'],
    );
  }

  // Method to convert a Profile to a map (e.g., for Firebase document)
  Map<String, dynamic> toFirebase() {
    return {
      'created': Timestamp.fromDate(created),
      'isDefault': isDefault,
      'name': name,
      'userRef': userRef,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Profile copyWith({
    DateTime? created,
    String? id,
    bool? isDefault,
    String? name,
    String? userRef,
  }) {
    return Profile(
      created: created ?? this.created,
      id: id ?? this.id,
      isDefault: isDefault ?? this.isDefault,
      name: name ?? this.name,
      userRef: userRef ?? this.userRef,
    );
  }
}

class Profiles {
  // Define your Profiles class properties and methods
  static Profiles fromFirebase(List<Map<String, dynamic>> data) {
    // Implement this method to create a Profiles instance from Firestore data
    return Profiles();
  }
}

// Define the state class
class ProfilesState {
  final Profile? profile;
  final List<Profile>? profiles;
  final bool isLoading;
  final String? error;

  ProfilesState({
    this.profile,
    this.profiles,
    this.isLoading = false,
    this.error,
  });

  ProfilesState copyWith({
    Profile? profile,
    List<Profile>? profiles,
    bool? isLoading,
    String? error,
  }) {
    return ProfilesState(
      profile: profile ?? this.profile,
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final profilesProvider =
    StateNotifierProvider<ProfilesNotifier, ProfilesState>((ref) {
  return ProfilesNotifier();
});

class ProfilesNotifier extends StateNotifier<ProfilesState> {
  ProfilesNotifier() : super(ProfilesState()) {
    loadCurrentUserProfile();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> loadCurrentUserProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = _auth.currentUser;
      if (user == null) {
        state = state.copyWith(profile: null, isLoading: false);
        return;
      }

      final userDocSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDocSnapshot.exists) {
        state = state.copyWith(profile: null, isLoading: false);
        return;
      }

      final userData = userDocSnapshot.data()!;
      String? profileId = userData['last_selected_profile'] as String?;

      if (profileId == null) {
        // If last_selected_profile is not set, find the default profile
        final profilesQuery = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('profiles')
            .where('isDefault', isEqualTo: true)
            .limit(1)
            .get();

        if (profilesQuery.docs.isNotEmpty) {
          profileId = profilesQuery.docs.first.id;
        }
      }

      if (profileId != null) {
        final profileDocSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('profiles')
            .doc(profileId)
            .get();

        if (profileDocSnapshot.exists) {
          // final profileData = profileDocSnapshot.data()!;
          final profile = Profile.fromFirebase(profileDocSnapshot, profileId);
          state = state.copyWith(profile: profile, isLoading: false);
          return;
        }
      }

      // If we get here, no profile was found
      state = state.copyWith(profile: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      print('Error loading profile: $e');
    }
  }

  Future<void> loadAllProfiles() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUser?.uid)
          .collection('profiles')
          .get();
      final profiles = querySnapshot.docs.map((doc) {
        final profile = Profile.fromFirebase(doc, doc.id);
        print(
            'Profile loaded: ${profile.name}, ID: ${profile.id}, IsDefault: ${profile.isDefault}');
        return profile;
      }).toList();

      state = ProfilesState(profile: state.profile, profiles: profiles);
    } catch (e) {
      // Handle error
      print('Error loading all profiles: $e');
    }
  }

  void setCurrentProfile(Profile profile) {
    state = state.copyWith(profile: profile);
  }

  // For example:
  Future<void> createProfile(Profile newProfile) async {
    try {
      final _repository = ProfileRepository();
      state = state.copyWith(isLoading: true, error: null);

      // Use the repository to add the profile
      await _repository.addProfile(newProfile);

      // Fetch all profiles to ensure consistency
      final updatedProfiles = await _repository.getAllProfiles();

      // Update the state with the new list of profiles
      state = state.copyWith(
        profiles: updatedProfiles,
        isLoading: false,
      );

      // If this is the first profile, set it as the current profile
      if (state.profile == null) {
        state = state.copyWith(profile: newProfile);
      }

      // If this is the only profile, set it as default
      // if (updatedProfiles.length == 1) {
      //   await _repository.setDefaultProfile(newProfile.id);
      // }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error creating profile: $e',
      );
      print('Error creating profile: $e');
    }
  }

  Future<void> updateProfile(Profile updatedProfile) async {
    try {
      final _repository = ProfileRepository();
      state = state.copyWith(isLoading: true, error: null);

      // Update the profile in Firestore
      await _repository.updateProfile(updatedProfile);

      // Fetch all profiles to ensure consistency
      final updatedProfiles = await _repository.getAllProfiles();

      // Update the state with the new list of profiles
      state = state.copyWith(
        profiles: updatedProfiles,
        isLoading: false,
      );

      // If the updated profile was the current profile, update it
      if (state.profile?.id == updatedProfile.id) {
        state = state.copyWith(profile: updatedProfile);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error updating profile: $e',
      );
      print('Error updating profile: $e');
    }
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      final _repository = ProfileRepository();
      state = state.copyWith(isLoading: true, error: null);

      // Delete the profile from Firestore
      await _repository.deleteProfile(profileId);

      // Fetch all profiles to ensure consistency
      final updatedProfiles = await _repository.getAllProfiles();

      // Update the state with the new list of profiles
      state = state.copyWith(
        profiles: updatedProfiles,
        isLoading: false,
      );

      // If the deleted profile was the current profile, set current profile to null
      if (state.profile?.id == profileId) {
        state = state.copyWith(profile: null);
      }

      // If there are remaining profiles and no current profile, set the first one as current
      if (state.profile == null && updatedProfiles.isNotEmpty) {
        state = state.copyWith(profile: updatedProfiles.first);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error deleting profile: $e',
      );
      print('Error deleting profile: $e');
    }
  }
}
