import 'package:firebase_auth/firebase_auth.dart';
// 🔹 Add this

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Validate Password
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
    return null; // ✅ Password is valid
  }

  // 🔹 Sign Up User with Password Validation
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

  // 🔹 Log In User
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

  // 🔹 Sign Out User
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🔹 Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
