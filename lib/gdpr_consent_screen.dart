import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class GDPRConsentScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String name;

  const GDPRConsentScreen({
    Key? key,
    required this.userId,
    required this.email,
    required this.name
  }) : super(key: key);

  @override
  _GDPRConsentScreenState createState() => _GDPRConsentScreenState();
}

class _GDPRConsentScreenState extends State<GDPRConsentScreen> {
  bool _consentToDataProcessing = false;
  bool _consentToMarketing = false;

  void _proceedToApp() {
    if (!_consentToDataProcessing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You must consent to data processing to use the app"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

 Future<void> _declineConsent() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      // Attempt to delete user data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete().then((_) {
        print("✅ User document deleted from Firestore.");
      }).catchError((error) {
        print(" Error deleting user document from Firestore: $error");
      });

      // Delete user authentication account
      await user.delete();
      print("User authentication account deleted.");

      // Sign out user
      await FirebaseAuth.instance.signOut();
      print(" User signed out successfully.");
    }
  } catch (e) {
    print("Error in decline process: $e");
  }

  // Navigate back to login or onboarding screen
  if (mounted) {
    Navigator.pop(context);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text("Privacy Consent", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy & Data Protection",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Welcome ${widget.name},",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Text(
              "Before you start using our app, we need your consent on how we process your personal data. Please read the following information carefully.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Data We Collect",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "• Personal information (name, email)\n"
                    "• Usage data (recipes viewed, meal tracking)\n"
                    "• Device information\n"
                    "• Dietary preferences",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "How We Use Your Data",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "• To provide and improve our services\n"
                    "• To personalize your experience\n"
                    "• To communicate with you about your account\n"
                    "• To ensure security and prevent fraud",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Your Rights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Under GDPR, you have the right to access, rectify, erase, restrict processing, object to processing, and data portability. You can exercise these rights by contacting us at privacy@example.com.",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 25),
            CheckboxListTile(
              title: Text(
                "I consent to the processing of my personal data as described above (required)",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              value: _consentToDataProcessing,
              activeColor: Colors.green[600],
              onChanged: (value) {
                setState(() {
                  _consentToDataProcessing = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: Text(
                "I consent to receive marketing communications (optional)",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              value: _consentToMarketing,
              activeColor: Colors.green[600],
              onChanged: (value) {
                setState(() {
                  _consentToMarketing = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _proceedToApp,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  child: Text(
                    "Accept & Continue",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: _declineConsent, // Calls function to remove user data
                child: Text(
                  "Decline",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
