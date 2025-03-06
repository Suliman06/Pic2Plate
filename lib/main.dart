import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_page.dart';
import 'auth_selection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure Firebase initializes only if not already initialized
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🔥 Firebase Initialized Successfully!");
  } catch (e) {
    print("⚠️ Firebase Initialization Error: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthSelection(), // Ensure AuthSelection loads correctly
      routes: {
        "/auth": (context) => AuthSelection(),
        "/login": (context) => LoginScreen(),
        "/signup": (context) => SignupScreen(),
        "/home": (context) => HomePage(isPremiumUser: false),
      },
    );
  }
}
