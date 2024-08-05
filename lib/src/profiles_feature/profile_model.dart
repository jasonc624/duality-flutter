class Profile {
  final String id;
  final String name;
  final String? photoUrl;
  final String userId;
  final String? summary;
  final List<dynamic>? goals;

  Profile({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.userId,
    this.summary,
    this.goals,
  });

  // Factory constructor to create a Profile from a Firebase document (Map)
  factory Profile.fromFirebase(Map<String, dynamic> map, String documentId) {
    return Profile(
      id: documentId,
      name: map['name'],
      photoUrl: map['photoUrl'],
      userId: map['userId'],
      summary: map['summary'],
      goals: map['goals'] != null ? List<dynamic>.from(map['goals']) : null,
    );
  }

  // Method to convert a Profile to a map (e.g., for Firebase document)
  Map<String, dynamic> toFirebase() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'userId': userId,
      'summary': summary,
      'goals': goals,
    };
  }
}
