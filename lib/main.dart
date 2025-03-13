import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_page.dart';
import 'auth_selection.dart';
import 'favourites_page.dart';
import 'feedback_page.dart';
import 'history_page.dart';
import 'more_page.dart';
import 'privacy_policy_page.dart';
import 'settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: AuthSelection(),
      routes: {
        "/auth": (context) => AuthSelection(),
        "/login": (context) => LoginScreen(),
        "/signup": (context) => SignupScreen(),
        "/home": (context) => HomePage(isPremiumUser: false),
        "/favourites": (context) => FavouritesPage(),
        "/feedback": (context) => FeedbackPage(),
        "/history": (context) => HistoryPage(),
        "/more": (context) => MorePage(),
        "/privacy": (context) => PrivacyPolicyPage(),
        "/settings": (context) => SettingsPage(),
      },
    );
  }
}