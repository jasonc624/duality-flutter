import 'package:cloud_firestore/cloud_firestore.dart';

class BehaviorEntry {
  BehaviorEntry({
    this.id,
    required this.description,
    this.title,
    this.traitScores,
    DateTime? created,
    DateTime? updated,
  })  : created = created ?? DateTime.now(),
        updated = updated ?? DateTime.now();

  final String? id;
  final String description;
  String? title;
  Map<String, dynamic>? traitScores;
  final DateTime created;
  final DateTime updated;

  factory BehaviorEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BehaviorEntry(
      id: doc.id,
      description: data['description'] ?? '',
      title: data['title'],
      traitScores: data['traitScores'] != null
          ? Map<String, dynamic>.from(data['traitScores'])
          : null,
      created: (data['created'] as Timestamp?)?.toDate(),
      updated: (data['updated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'title': title,
      'traitScores': traitScores,
      'created': created,
      'updated': FieldValue.serverTimestamp(),
    };
  }

  BehaviorEntry copyWith({
    String? id,
    String? description,
    String? title,
    Map<String, dynamic>? traitScores,
    DateTime? created,
    DateTime? updated,
  }) {
    return BehaviorEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      title: title ?? this.title,
      traitScores: traitScores ?? this.traitScores,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // Helper methods to get trait score and reason
  double? getTraitScore(String trait) {
    return traitScores?[trait] as double?;
  }

  String? getTraitReason(String trait) {
    return traitScores?['${trait}_reason'] as String?;
  }
}
// const List<String> traitPairs = [
//   'compassionate_callous',
//   'honest_deceitful',
//   'courageous_cowardly',
//   'ambitious_lazy',
//   'generous_greedy',
//   'patient_impatient',
//   'humble_arrogant',
//   'loyal_disloyal',
//   'optimistic_pessimistic',
//   'responsible_irresponsible',
// ];