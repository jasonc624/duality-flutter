import 'package:cloud_firestore/cloud_firestore.dart';

class Relationship {
  final String id;
  final String name;
  final String? type;
  final List<String> tags;
  final List<String> profiles;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Relationship({
    required this.id,
    required this.name,
    this.type,
    this.tags = const [],
    this.profiles = const [],
    this.notes,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a Relationship object from a Firestore document
  factory Relationship.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Relationship(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'],
      tags: List<String>.from(data['tags'] ?? []),
      profiles: List<String>.from(data['profiles'] ?? []),
      notes: data['notes'],
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
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
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
    DateTime? updatedAt,
  }) {
    return Relationship(
      id: this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      profiles: profiles ?? this.profiles,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
