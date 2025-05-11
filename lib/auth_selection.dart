import 'package:flutter/material.dart';

class AuthSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("AuthSelection Screen Loaded!");

    return Scaffold(
      backgroundColor: Colors.green[600],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Pic2Plate",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),

              // Log In button
              _buildButton(
                context,
                label: "Log In",
                routeName: "/login",
              ),
              SizedBox(height: 16),

              // Sign Up button 
              _buildButton(
                context,
                label: "Sign Up",
                routeName: "/signup",
              ),
              SizedBox(height: 16),

              // Admin login button
              _buildButton(
                  context,
                  label: "Sign in as Admin",
                  routeName: "/admin",
                  isPrimary: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {
    required String label,
    required String routeName,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, routeName),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.blue : Colors.white,
        foregroundColor: isPrimary ? Colors.white : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: Size(250, 50),
      ),
      child: Text(label, style: TextStyle(fontSize: 18)),
    );
  }

}