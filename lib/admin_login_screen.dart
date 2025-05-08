import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_home_page.dart'; // Replace with your actual admin page

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loginAsAdmin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Administrators')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = "No admin found with this email.";
          _isLoading = false;
        });
        return;
      }

      final adminData = snapshot.docs.first.data();
      final storedHash = adminData['passwordHash'];

      // Placeholder hash check (replace with real hash logic)
      if (storedHash == password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHomePage()),
        );
      } else {
        setState(() {
          _errorMessage = "Incorrect password.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Login error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Sign in as Admin", style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Admin Email"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter your email" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter your password" : null,
              ),
              SizedBox(height: 24),
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    _loginAsAdmin();
                  }
                },
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text("Login as Admin"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
