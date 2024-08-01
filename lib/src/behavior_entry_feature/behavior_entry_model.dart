import 'package:cloud_firestore/cloud_firestore.dart';

class BehaviorEntry {
  BehaviorEntry({
    this.id,
    required this.description,
    required this.userRef,
    this.title,
    this.traitScores,
    DateTime? created,
    DateTime? updated,
    this.mentions,
    this.isPublic = false,
  })  : created = created ?? DateTime.now(),
        updated = updated ?? DateTime.now();

  final String? id;
  final String description;
  String userRef;
  String? title;
  Map<String, dynamic>? traitScores;
  final List<String>? mentions;
  final DateTime created;
  final DateTime updated;
  final bool? isPublic;

  factory BehaviorEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BehaviorEntry(
      id: doc.id,
      description: data['description'] ?? '',
      userRef: data['userRef'] as String,
      isPublic: data['isPublic'] as bool,
      title: data['title'],
      traitScores: data['traitScores'] != null
          ? Map<String, dynamic>.from(data['traitScores'])
          : null,
      mentions: (data['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
      created: (data['created'] as Timestamp?)?.toDate(),
      updated: (data['updated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'userRef': userRef,
      'title': title,
      'mentions': mentions,
      'traitScores': traitScores,
      'created': created,
      'updated': FieldValue.serverTimestamp(),
      'isPublic': isPublic,
    };
  }

  BehaviorEntry copyWith({
    String? id,
    String? description,
    String? userRef,
    String? title,
    Map<String, dynamic>? traitScores,
    dynamic mentions,
    DateTime? created,
    DateTime? updated,
    bool? isPublic,
  }) {
    return BehaviorEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      userRef: userRef ?? this.userRef,
      title: title ?? this.title,
      traitScores: traitScores ?? this.traitScores,
      mentions: mentions ?? this.mentions,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // Helper methods remain unchanged
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