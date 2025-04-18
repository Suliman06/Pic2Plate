import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  String name;
  String email;
  String membershipTier;
  List<String> dietaryPreferences;
  List<String> allergies; 

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.membershipTier,
    required this.dietaryPreferences,
    this.allergies = const [],
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      membershipTier: map['membershipTier'] ?? 'free',
      dietaryPreferences: List<String>.from(map['dietaryPreferences'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'membershipTier': membershipTier,
      'dietaryPreferences': dietaryPreferences,
      'allergies': allergies,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}