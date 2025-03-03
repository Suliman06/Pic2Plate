import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 Save User Data on Sign Up
  Future<void> saveUserData(String userId, String email, String name) async {
    try {
      await _db.collection("Users").doc(userId).set({
        "userId": userId,
        "email": email,
        "name": name,
        "profileImage": "",
        "membershipTier": "free",
        "dietaryPreferences": [],
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      print("✅ User data saved successfully");
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }

  // 🔹 Get User Data
  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _db.collection("Users").doc(userId).get();
  }
}
