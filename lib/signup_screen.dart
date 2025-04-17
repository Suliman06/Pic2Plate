import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gdpr_consent_screen.dart';
import 'widgets/mfa_dialogs.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<String> _verifyPhoneNumber(String phoneNumber) {
    final Completer<String> completer = Completer<String>();
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        completer.complete('');
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        completer.complete(verificationId);
      },
    );
    return completer.future;
  }

  void _signUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String phoneNumber = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter all fields"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final verificationId = await _verifyPhoneNumber(phoneNumber);

      if (verificationId.isNotEmpty) {
        final smsCode = await promptUserForSmsCode(context);

        final phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
        final user = userCredential.user;

        if (user != null) {
          // Now link email/password to this phone-authenticated user
          final emailCredential = EmailAuthProvider.credential(
            email: email,
            password: password,
          );

          await user.linkWithCredential(emailCredential);

          // Save user data to Firestore
          await _firestoreService.saveUserData(user.uid, email, name);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sign-Up Successful!"), backgroundColor: Colors.green),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GDPRConsentScreen(
                userId: user.uid,
                email: email,
                name: name,
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
