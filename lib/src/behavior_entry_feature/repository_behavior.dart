import 'package:cloud_firestore/cloud_firestore.dart';

import 'behavior_entry_model.dart';

class BehaviorRepository {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('behaviors');

  // Create a new behavior entry
  Future<String> addBehavior(BehaviorEntry entry) async {
    DocumentReference docRef = await _collection.add(entry.toFirestore());
    return docRef.id;
  }

  // Read a single behavior entry
  Future<BehaviorEntry> getBehavior(String id) async {
    DocumentSnapshot doc = await _collection.doc(id).get();
    return BehaviorEntry.fromFirestore(doc);
  }

  // Read all behavior entries
  Stream<List<BehaviorEntry>> getBehaviors() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BehaviorEntry.fromFirestore(doc))
          .toList();
    });
  }

  // Update an existing behavior entry
  Future<void> updateBehavior(BehaviorEntry entry) async {
    if (entry.id == null) {
      throw Exception('Cannot update an entry without an ID');
    }
    await _collection.doc(entry.id).update({
      'description': entry.description,
      'updated': FieldValue.serverTimestamp(),
    });
  }

  // Delete a behavior entry
  Future<void> deleteBehavior(String id) async {
    await _collection.doc(id).delete();
  }
}
