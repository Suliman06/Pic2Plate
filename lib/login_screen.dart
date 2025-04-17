import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'home_page.dart';
import 'widgets/mfa_dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuthException

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      print("🔥 Please enter email and password");
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);

        if (userData.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          print("🔥 User data not found in Firestore!");
        }
      } else {
        print("🔥 Login Failed!");
      }
    } on FirebaseAuthMultiFactorException catch (e) {
      print("🔒 MFA Required!");

      final resolver = e.resolver;
      // Cast the first enrolled factor to PhoneMultiFactorInfo
      final phoneHint = resolver.hints.first as PhoneMultiFactorInfo;
      final session = resolver.session;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneHint.phoneNumber,
        multiFactorSession: session,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Auto verified!");
        },
        verificationFailed: (FirebaseAuthException error) {
          print('Verification failed: ${error.message}');
        },
        codeSent: (String verificationId, int? resendToken) async {
          final smsCode = await promptUserForSmsCode(context);

          final phoneAuthCredential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );

          final assertion = PhoneMultiFactorGenerator.getAssertion(phoneAuthCredential);

          await resolver.resolveSignIn(assertion);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      print('Sign-In Error: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text("Log In"),
            ),
          ],
        ),
      ),
    );
  }
}
