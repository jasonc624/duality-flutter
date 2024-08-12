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
    this.disorders,
    this.environmental,
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
  final num? overall_score;
  final List<Disorder>? disorders;
  final List<Environmental>? environmental;

  factory BehaviorEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BehaviorEntry(
      id: doc.id,
      description: data['description'] ?? '',
      userRef: data['userRef'] as String,
      profile: data['profile'] as String?,
      isPublic: data['isPublic'] as bool?,
      title: data['title'] as String?,
      traitScores: data['traitScores'] != null
          ? Map<String, dynamic>.from(data['traitScores'])
          : null,
      mentions: (data['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
      created: (data['created'] as Timestamp?)?.toDate(),
      updated: (data['updated'] as Timestamp?)?.toDate(),
      suggestion: data['suggestion'] as String?,
      overall_score: data['overall_score'] as num?,
      disorders: (data['disorders'] as List<dynamic>?)
          ?.map((e) => Disorder.fromMap(e as Map<String, dynamic>))
          .toList(),
      environmental: (data['environmental'] as List<dynamic>?)
          ?.map((e) => Environmental.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = {
      'description': description,
      'userRef': userRef,
      'title': title,
      'mentions': mentions,
      'traitScores': traitScores,
      'created': created,
      'updated': FieldValue.serverTimestamp(),
      'isPublic': isPublic,
      'suggestion': suggestion,
      'overall_score': overall_score,
    };

    if (profile != null) {
      data['profile'] = profile;
    }

    if (disorders != null) {
      data['disorders'] = disorders!.map((d) => d.toMap()).toList();
    }

    if (environmental != null) {
      data['environmental'] = environmental!.map((e) => e.toMap()).toList();
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
    num? overall_score,
    List<Disorder>? disorders,
    List<Environmental>? environmental,
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
      disorders: disorders ?? this.disorders,
      environmental: environmental ?? this.environmental,
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

// Disorder class remains unchanged
class Disorder {
  final String name;
  final String reason;
  final int score;

  Disorder({required this.name, required this.reason, required this.score});

  factory Disorder.fromMap(Map<String, dynamic> map) {
    return Disorder(
      name: map['name'] as String,
      reason: map['reason'] as String,
      score: map['score'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reason': reason,
      'score': score,
    };
  }
}

// New Environmental class
class Environmental {
  final String name;
  final String reason;
  final int score;

  Environmental(
      {required this.name, required this.reason, required this.score});

  factory Environmental.fromMap(Map<String, dynamic> map) {
    return Environmental(
      name: map['name'] as String,
      reason: map['reason'] as String,
      score: map['score'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reason': reason,
      'score': score,
    };
  }
}
