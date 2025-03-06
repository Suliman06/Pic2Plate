import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showLoginFields = false;
  bool _obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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

            if (!showLoginFields)
              Icon(
                Icons.fastfood,
                size: 100,
                color: Colors.white,
              ),

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
                      onPressed: () {},
                      child: Text(
                        "Sign Up for Free",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

                  if (showLoginFields) ...[
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

                    TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.green[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

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
                        bool isPremiumUser = true;
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