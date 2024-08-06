import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'relationship_model.dart';

class RelationshipRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the relationships collection for the current user
  CollectionReference<Map<String, dynamic>> _getRelationshipsCollection() {
    String userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('relationships');
  }

  // Create a new relationship
  Future<String> createRelationship(Relationship relationship) async {
    try {
      DocumentReference docRef =
          await _getRelationshipsCollection().add(relationship.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating relationship: $e');
      throw e;
    }
  }

  // Get a single relationship by ID
  Future<Relationship?> getRelationship(String id) async {
    try {
      DocumentSnapshot doc = await _getRelationshipsCollection().doc(id).get();
      if (doc.exists) {
        return Relationship.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting relationship: $e');
      throw e;
    }
  }

  // Get all relationships for the current user
  Stream<List<Relationship>> getAllRelationships() {
    return _getRelationshipsCollection().snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Relationship.fromFirestore(doc))
          .toList();
    });
  }

  // Update a relationship
  Future<void> updateRelationship(Relationship relationship) async {
    try {
      await _getRelationshipsCollection()
          .doc(relationship.id)
          .update(relationship.toFirestore());
    } catch (e) {
      print('Error updating relationship: $e');
      throw e;
    }
  }

  // Delete a relationship
  Future<void> deleteRelationship(String id) async {
    try {
      await _getRelationshipsCollection().doc(id).delete();
    } catch (e) {
      print('Error deleting relationship: $e');
      throw e;
    }
  }

  // Add a tag to a relationship
  Future<void> addTagToRelationship(String relationshipId, String tag) async {
    try {
      Relationship? relationship = await getRelationship(relationshipId);
      if (relationship != null) {
        Relationship updatedRelationship = relationship.addTag(tag);
        await updateRelationship(updatedRelationship);
      }
    } catch (e) {
      print('Error adding tag to relationship: $e');
      throw e;
    }
  }

  // Remove a tag from a relationship
  Future<void> removeTagFromRelationship(
      String relationshipId, String tag) async {
    try {
      Relationship? relationship = await getRelationship(relationshipId);
      if (relationship != null) {
        Relationship updatedRelationship = relationship.removeTag(tag);
        await updateRelationship(updatedRelationship);
      }
    } catch (e) {
      print('Error removing tag from relationship: $e');
      throw e;
    }
  }

  // Add a profile to a relationship
  Future<void> addProfileToRelationship(
      String relationshipId, String profile) async {
    try {
      Relationship? relationship = await getRelationship(relationshipId);
      if (relationship != null) {
        Relationship updatedRelationship = relationship.addProfile(profile);
        await updateRelationship(updatedRelationship);
      }
    } catch (e) {
      print('Error adding profile to relationship: $e');
      throw e;
    }
  }

  // Remove a profile from a relationship
  Future<void> removeProfileFromRelationship(
      String relationshipId, String profile) async {
    try {
      Relationship? relationship = await getRelationship(relationshipId);
      if (relationship != null) {
        Relationship updatedRelationship = relationship.removeProfile(profile);
        await updateRelationship(updatedRelationship);
      }
    } catch (e) {
      print('Error removing profile from relationship: $e');
      throw e;
    }
  }

  // Update metadata of a relationship
  Future<void> updateRelationshipMetadata(
      String relationshipId, Map<String, dynamic> newMetadata) async {
    try {
      Relationship? relationship = await getRelationship(relationshipId);
      if (relationship != null) {
        Relationship updatedRelationship =
            relationship.updateMetadata(newMetadata);
        await updateRelationship(updatedRelationship);
      }
    } catch (e) {
      print('Error updating relationship metadata: $e');
      throw e;
    }
  }
}
