import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? validatePassword(String password) {
    if (!RegExp(r'^(?=.*[a-z])').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'^(?=.*\d)').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  Future<User?> signUp(String email, String password) async {
    String? validationError = validatePassword(password);

    if (validationError != null) {
      throw FirebaseAuthException(
        code: 'invalid-password',
        message: validationError,
      );
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Sign In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> resetPassword(String userId, String newPassword) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        print('No signed-in user for password reset.');
        return;
      }

      await user.updatePassword(newPassword);

      await _firestore.collection('users').doc(userId).update({
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
        'passwordResetComplete': true,
      });
    } catch (e) {
      print('Error resetting password: $e');
      throw e;
    }
  }
}
