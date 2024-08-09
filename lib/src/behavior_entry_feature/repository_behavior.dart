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
      List<BehaviorEntry> behaviors =
          snapshot.docs.map((doc) => BehaviorEntry.fromFirestore(doc)).toList();
      behaviors.forEach((behavior) {
        print('Behavior: ${behavior.title}, ${behavior.description}');
      });

      return behaviors;
    });
  }

  Stream<List<BehaviorEntry>> getBehaviorsByDate(
      DateTime date, String? userRef) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay =
        startOfDay.add(Duration(days: 1)).subtract(Duration(microseconds: 1));

    return _collection
        .where('created',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('created', isLessThan: Timestamp.fromDate(endOfDay))
        .where('userRef', isEqualTo: userRef.toString())
        .snapshots()
        .map((snapshot) {
      List<BehaviorEntry> behaviors =
          snapshot.docs.map((doc) => BehaviorEntry.fromFirestore(doc)).toList();

      // Sort the behaviors list in descending order of creation time
      behaviors.sort((a, b) => b.created.compareTo(a.created));

      return behaviors;
    });
  }

  Stream<Map<int, List<BehaviorEntry>>> getBehaviorsForWeek(
      DateTime startDate, DateTime endDate, String userRef) {
    return _collection
        .where('created', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('created', isLessThan: Timestamp.fromDate(endDate))
        .where('userRef', isEqualTo: userRef)
        .snapshots()
        .map((snapshot) {
      List<BehaviorEntry> behaviors =
          snapshot.docs.map((doc) => BehaviorEntry.fromFirestore(doc)).toList();

      // Sort the behaviors list in ascending order of creation time
      behaviors.sort((a, b) => a.created.compareTo(b.created));

      // Group behaviors by day of the week (0-6)
      Map<int, List<BehaviorEntry>> behaviorsByDay = {};
      for (var behavior in behaviors) {
        int dayOfWeek = behavior.created.difference(startDate).inDays;
        if (dayOfWeek >= 0 && dayOfWeek < 7) {
          behaviorsByDay.putIfAbsent(dayOfWeek, () => []).add(behavior);
        }
      }

      return behaviorsByDay;
    });
  }

  // Update an existing behavior entry
  Future<void> updateBehavior(BehaviorEntry entry) async {
    if (entry.id == null) {
      throw Exception('Cannot update an entry without an ID');
    }
    await _collection.doc(entry.id).update({
      'created': entry.created,
      'mentions': entry.mentions,
      'profile': entry.profile,
      'description': entry.description,
      'updated': FieldValue.serverTimestamp(),
    });
  }

  // Delete a behavior entry
  Future<void> deleteBehavior(String id) async {
    await _collection.doc(id).delete();
  }
}
