// Service for handling user authentication using Firebase Auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Validate password rules: must include uppercase, lowercase, number
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
    return null; // Valid password
  }

  // Register user with email and password after validation
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

  // Authenticate user with email and password
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

  // Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Retrieve the current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
