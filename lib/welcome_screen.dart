import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App title
            Text(
              "Pic2Plate",
              style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),

            // Login button
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/login"),
              child: Text("Login"),
            ),

            // Sign up button
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/signup"),
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
