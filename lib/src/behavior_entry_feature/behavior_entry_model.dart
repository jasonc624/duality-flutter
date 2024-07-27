import 'package:cloud_firestore/cloud_firestore.dart';

class BehaviorEntry {
  BehaviorEntry({
    this.id,
    required this.description,
    this.title,
    this.traitScores,
  });

  final String? id;
  final String description;
  String? title;
  Map<String, double>? traitScores;
  late final DateTime created;
  late final DateTime updated;

  factory BehaviorEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BehaviorEntry(
      id: doc.id,
      description: data['description'],
      title: data['title'],
      traitScores: data['traitScores'] != null
          ? Map<String, double>.from(data['traitScores'])
          : null,
    )
      ..created = (data['created'] as Timestamp).toDate()
      ..updated = (data['updated'] as Timestamp).toDate();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'title': title,
      'traitScores': traitScores,
      'created': FieldValue.serverTimestamp(),
      'updated': FieldValue.serverTimestamp(),
    };
  }

  BehaviorEntry copyWith({
    String? id,
    String? description,
    String? title,
    Map<String, double>? traitScores,
  }) {
    return BehaviorEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      title: title ?? this.title,
      traitScores: traitScores ?? this.traitScores,
    );
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