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

  Future<void> createRelationship(Map<String, dynamic> relationshipData) async {
    try {
      await _getRelationshipsCollection().add({
        ...relationshipData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating relationship: $e');
      throw e;
    }
  }

  Future<void> updateRelationship(
      String relationshipId, Map<String, dynamic> relationshipData) async {
    try {
      await _getRelationshipsCollection().doc(relationshipId).update({
        ...relationshipData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating relationship: $e');
      throw e;
    }
  }

  // Get a relationship by ID
  Future<Map<String, dynamic>?> getRelationshipById(
      String relationshipId) async {
    try {
      final docSnapshot =
          await _getRelationshipsCollection().doc(relationshipId).get();
      return docSnapshot.data();
    } catch (e) {
      print('Error getting relationship: $e');
      throw e;
    }
  }

  // Delete a relationship
  Future<void> deleteRelationship(String relationshipId) async {
    try {
      await _getRelationshipsCollection().doc(relationshipId).delete();
    } catch (e) {
      print('Error deleting relationship: $e');
      throw e;
    }
  }

  Stream<List<Relationship>> getRelationships() {
    return _getRelationshipsCollection().snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Relationship.fromFirestore(doc))
          .toList();
    });
  }
}
