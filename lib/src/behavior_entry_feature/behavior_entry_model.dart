import 'package:cloud_firestore/cloud_firestore.dart';

class BehaviorEntry {
  BehaviorEntry({
    this.id,
    required this.description,
    required this.userRef,
    this.profile,
    this.title,
    this.traitScores,
    DateTime? created,
    DateTime? updated,
    this.mentions,
    this.isPublic = false,
    this.suggestion,
    this.overall_score,
  })  : created = created ?? DateTime.now(),
        updated = updated ?? DateTime.now();

  final String? id;
  final String description;
  String userRef;
  final String? profile;
  String? title;
  Map<String, dynamic>? traitScores;
  final List<String>? mentions;
  final DateTime created;
  final DateTime updated;
  final bool? isPublic;
  final String? suggestion;
  final int? overall_score;

  factory BehaviorEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BehaviorEntry(
      id: doc.id,
      description: data['description'] ?? '',
      userRef: data['userRef'] as String,
      profile: data['profile'] as String?,
      isPublic: data['isPublic'] as bool?,
      title: data['title'],
      traitScores: data['traitScores'] != null
          ? Map<String, dynamic>.from(data['traitScores'])
          : null,
      mentions: (data['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
      created: (data['created'] as Timestamp?)?.toDate(),
      updated: (data['updated'] as Timestamp?)?.toDate(),
      suggestion: data['suggestion'] as String?,
      overall_score: data['overall_score'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'description': description,
      'userRef': userRef,
      'title': title,
      'mentions': mentions,
      'traitScores': traitScores,
      'created': created,
      'updated': FieldValue.serverTimestamp(),
      'isPublic': isPublic,
    };

    if (profile != null) {
      data['profile'] = profile;
    }

    return data;
  }

  BehaviorEntry copyWith({
    String? id,
    String? description,
    String? userRef,
    String? profile,
    String? title,
    Map<String, dynamic>? traitScores,
    dynamic mentions,
    DateTime? created,
    DateTime? updated,
    bool? isPublic,
    String? suggestion,
    int? overall_score,
  }) {
    return BehaviorEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      userRef: userRef ?? this.userRef,
      profile: profile ?? this.profile,
      title: title ?? this.title,
      traitScores: traitScores ?? this.traitScores,
      mentions: mentions ?? this.mentions,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      isPublic: isPublic ?? this.isPublic,
      suggestion: suggestion ?? this.suggestion,
      overall_score: overall_score ?? this.overall_score,
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
