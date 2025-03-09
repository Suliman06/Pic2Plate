import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pic2Plate", style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/login"),
              child: Text("Login"),
            ),
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
