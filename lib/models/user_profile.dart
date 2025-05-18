import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final Map<String, int> statistics;
  final List<String> achievements;
  final DateTime joinedDate;
  final Map<String, dynamic> preferences;

  UserProfile({
    String? id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    Map<String, int>? statistics,
    List<String>? achievements,
    DateTime? joinedDate,
    Map<String, dynamic>? preferences,
  })  : id = id ?? const Uuid().v4(),
        statistics = statistics ?? {},
        achievements = achievements ?? [],
        joinedDate = joinedDate ?? DateTime.now(),
        preferences = preferences ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'statistics': statistics,
      'achievements': achievements,
      'joinedDate': joinedDate.toIso8601String(),
      'preferences': preferences,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      statistics: Map<String, int>.from(json['statistics'] as Map),
      achievements: List<String>.from(json['achievements'] as List),
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      preferences: json['preferences'] as Map<String, dynamic>,
    );
  }

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    Map<String, int>? statistics,
    List<String>? achievements,
    DateTime? joinedDate,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      statistics: statistics ?? this.statistics,
      achievements: achievements ?? this.achievements,
      joinedDate: joinedDate ?? this.joinedDate,
      preferences: preferences ?? this.preferences,
    );
  }
}
