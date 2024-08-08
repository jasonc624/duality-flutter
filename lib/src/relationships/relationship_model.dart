import 'package:cloud_firestore/cloud_firestore.dart';

class Relationship {
  final String id;
  final String name;
  String? type;
  List<String> tags;
  List<String> profiles;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, dynamic> current_standing;
  Map<String, dynamic>? metadata;

  Relationship({
    required this.id,
    required this.name,
    this.type,
    List<String>? tags,
    List<String>? profiles,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? current_standing,
    Map<String, dynamic>? metadata,
  })  : this.tags = tags ?? [],
        this.profiles = profiles ?? [],
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now(),
        this.current_standing = current_standing ??
            {'emoji': 'none', 'summary': 'This is a new relationship'},
        this.metadata = metadata ??
            {
              'traitScores': {
                'compassionate_callous': 0,
                'honest_deceitful': 0,
                'courageous_cowardly': 0,
                'ambitious_lazy': 0,
                'generous_greedy': 0,
                'patient_impatient': 0,
                'humble_arrogant': 0,
                'loyal_disloyal': 0,
                'optimistic_pessimistic': 0,
                'responsible_irresponsible': 0
              }
            };
  factory Relationship.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Relationship(
      id: doc.id,
      name: data['name'],
      type: data['type'],
      tags: List<String>.from(data['tags'] ?? []),
      profiles: List<String>.from(data['profiles'] ?? []),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      current_standing: data['current_standing'] ??
          {'emoji': 'none', 'summary': 'This is a new relationship'},
      metadata: data['metadata'],
    );
  }

  // Convert Relationship object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'tags': tags,
      'profiles': profiles,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'current_standing': current_standing,
      'metadata': metadata,
    };
  }

  // Create a copy of the Relationship object with updated fields
  Relationship copyWith({
    String? name,
    String? type,
    List<String>? tags,
    List<String>? profiles,
    String? notes,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? current_standing,
    DateTime? updatedAt,
  }) {
    return Relationship(
      id: this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      profiles: profiles ?? this.profiles,
      notes: notes ?? this.notes,
      metadata: metadata != null ? Map.from(metadata) : this.metadata,
      current_standing: current_standing != null
          ? Map.from(current_standing)
          : this.current_standing,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get currentStandingEmoji => current_standing['emoji'] as String;
  String get currentStandingSummary => current_standing['summary'] as String;

  // Update current_standing
  Relationship updateCurrentStanding({String? emoji, String? summary}) {
    Map<String, dynamic> newCurrentStanding = Map.from(current_standing);
    if (emoji != null) newCurrentStanding['emoji'] = emoji;
    if (summary != null) newCurrentStanding['summary'] = summary;

    return copyWith(
      current_standing: newCurrentStanding,
      updatedAt: DateTime.now(),
    );
  }

  // Add a new tag
  Relationship addTag(String tag) {
    if (!tags.contains(tag)) {
      return copyWith(
        tags: [...tags, tag],
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  // Remove a tag
  Relationship removeTag(String tag) {
    return copyWith(
      tags: tags.where((t) => t != tag).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Add a profile
  Relationship addProfile(String profile) {
    if (!profiles.contains(profile)) {
      return copyWith(
        profiles: [...profiles, profile],
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  // Remove a profile
  Relationship removeProfile(String profile) {
    return copyWith(
      profiles: profiles.where((p) => p != profile).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Update metadata
  Relationship updateMetadata(Map<String, dynamic> newMetadata) {
    return copyWith(
      metadata: {...?metadata, ...newMetadata},
      updatedAt: DateTime.now(),
    );
  }
}
