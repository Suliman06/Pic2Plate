import 'package:flutter/material.dart';
import 'home_page.dart'; // Import home page

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showLoginFields = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600], // Adjusted color theme
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App Title at the top
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                "Pic2Plate",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Arial',
                ),
              ),
            ),

            // App Icon in the middle
            if (!showLoginFields)
              Icon(
                Icons.fastfood, // Placeholder icon
                size: 100,
                color: Colors.white,
              ),

            // Login & Sign-up buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  if (!showLoginFields)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        setState(() {
                          showLoginFields = true;
                        });
                      },
                      child: Text("Log In", style: TextStyle(fontSize: 18)),
                    ),

                  if (!showLoginFields) SizedBox(height: 10),

                  if (!showLoginFields)
                    TextButton(
                      onPressed: () {
                        // TODO: Implement sign-up functionality
                      },
                      child: Text(
                        "Sign Up for Free",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

                  if (showLoginFields) ...[
                    // Email Field
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.green[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.green[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Login Button (After fields appear)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        bool isPremiumUser = true; // Simulating premium status
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(isPremiumUser: isPremiumUser),
                          ),
                        );
                      },
                      child: Text("Continue", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
