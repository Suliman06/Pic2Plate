import 'package:flutter/material.dart';
import 'auth_service.dart';

class HomePage extends StatefulWidget {
  final bool isPremiumUser;

  const HomePage({Key? key, this.isPremiumUser = false}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
     print("HomePage Loaded! isPremiumUser: ${widget.isPremiumUser}");

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
              Navigator.pushReplacementNamed(context, "/auth");
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to Home!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (widget.isPremiumUser) ...[
              SizedBox(height: 20),
              Text(
                "🎉 You are a Premium User! 🎉",
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
