import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
        backgroundColor: Colors.green[600],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            "Privacy Policy\n\n"
                "At Pic2Plate, we take your privacy seriously. This Privacy Policy explains how we collect, use, and protect your information.\n\n"
                "1. Information We Collect\n"
                "We collect information you provide when you use our app, such as your name, email address, and preferences.\n\n"
                "2. How We Use Your Information\n"
                "We use your information to provide and improve our services, personalize your experience, and communicate with you.\n\n"
                "3. Data Security\n"
                "We implement security measures to protect your data from unauthorized access or disclosure.\n\n"
                "4. Changes to This Policy\n"
                "We may update this Privacy Policy from time to time. Please review it periodically.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}