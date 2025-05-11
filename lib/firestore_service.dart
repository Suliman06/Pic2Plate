import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // save user profile data on sign up
  Future<void> saveUserData(String userId, String email, String name, {String? phoneNumber}) async {
    try {
      Map<String, dynamic> userData = {
        "userId": userId,
        "email": email,
        "name": name,
        "profileImage": "",
        "membershipTier": "free",
        "dietaryPreferences": [],
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      };

      if (phoneNumber != null) {
        userData["phoneNumber"] = phoneNumber;
      }

      await _db.collection("Users").doc(userId).set(userData);
      print("User data saved successfully");
    } catch (e) {
      print("Firestore Error: $e");
    }
  }

  // retrieve user profile document by userId
  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _db.collection("Users").doc(userId).get();
  }

  // find user by email
  Future<QuerySnapshot> getUserByEmail(String email) async {
    return await _db
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
  }

  // update full user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _db.collection("Users").doc(profile.userId).update(profile.toMap());
      print("User profile updated successfully");
    } catch (e) {
      print("Firestore Error: $e");
      throw e;
    }
  }

  Future<void> updateUserField(String userId, String field, dynamic value) async {
    try {
      await _db.collection("Users").doc(userId).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("User field '$field' updated successfully");
    } catch (e) {
      print("Firestore Error: $e");
      throw e;
    }
  }

  Future<void> updateUserPassword(String uid, String newPassword) async {
    try {
      await _db.collection('Users').doc(uid).update({
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
        'passwordResetComplete': true,
      });
    } catch (e) {
      print("Firestore Error: $e");
      throw e;
    }
  }

  Future<void> addUser(String uid, Map<String, dynamic> userData) async {
    return await _db.collection('Users').doc(uid).set(userData);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    return await _db.collection('Users').doc(uid).update(userData);
  }

  // make sure 'allergies' field exists 
  Future<void> ensureUserHasAllergiesField(String userId) async {
    final doc = await getUserData(userId);
    if (doc.exists && !(doc.data() as Map<String, dynamic>).containsKey('allergies')) {
      await _db.collection("Users").doc(userId).update({
        'allergies': [],
      });
    }
  }
}