import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/profileState.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the profiles collection reference for the current user
  CollectionReference<Map<String, dynamic>> get _profilesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('profiles');
  }

  // Fetch all profiles for the current user
  Future<List<Profile>> getAllProfiles() async {
    try {
      final querySnapshot = await _profilesCollection.get();
      return querySnapshot.docs
          .map((doc) => Profile.fromFirebase(doc, doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add a new profile
  Future<Profile> addProfile(Profile profile) async {
    try {
      // Create a new document reference with a generated ID
      final docRef = _profilesCollection.doc();

      // Create a new profile with the generated ID
      final newProfile = profile.copyWith(id: docRef.id);

      // Set the data for the new profile
      await docRef.set(newProfile.toFirebase());

      return newProfile;
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing profile
  Future<void> updateProfile(Profile profile) async {
    try {
      await _profilesCollection.doc(profile.id).update(profile.toFirebase());
    } catch (e) {
      // print('Error updating profile: $e');
      rethrow;
    }
  }

  // Delete a profile
  Future<void> deleteProfile(String profileId) async {
    try {
      await _profilesCollection.doc(profileId).delete();
    } catch (e) {
      // print('Error deleting profile: $e');
      rethrow;
    }
  }

  // Set a profile as default
  Future<void> setDefaultProfile(String profileId) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();

      // Set all profiles to non-default
      final allProfiles = await _profilesCollection.get();
      for (var doc in allProfiles.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set the selected profile as default
      batch.update(_profilesCollection.doc(profileId), {'isDefault': true});

      // Commit the batch
      await batch.commit();
    } catch (e) {
      // print('Error setting default profile: $e');
      rethrow;
    }
  }
}
