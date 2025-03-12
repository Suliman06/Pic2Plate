import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'home_page.dart';

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

  final user = await _authService.signIn(email, password);

  if (user != null) {
    final userData = await _firestoreService.getUserData(user.uid);

    if (userData.exists) {
      print("✅ Login Successful: ${user.email}");
      print("📌 User Name: ${userData["name"]}");
      print("📌 Membership Tier: ${userData["membershipTier"]}");
      print("📌 Dietary Preferences: ${userData["dietaryPreferences"]}");

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
