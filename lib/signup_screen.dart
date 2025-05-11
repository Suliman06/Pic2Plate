import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gdpr_consent_screen.dart';
import 'widgets/mfa_dialogs.dart';
import 'login_screen.dart'; 

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureText = true;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _phoneError;

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Password validation
  bool _isPasswordValid(String password) {
       final RegExp passwordRegExp = 
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  // Check if email already exists in Firebase
  Future<bool> _checkIfEmailExists(String email) async {
    try {
      var methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Validate all inputs 
  Future<bool> _validateInputs() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _phoneError = null;
    });

    bool isValid = true;
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String phoneNumber = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter your name';
      });
      isValid = false;
    }
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email';
      });
      isValid = false;
    } else if (!_isValidEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      isValid = false;
    } else {
      bool emailExists = await _checkIfEmailExists(email);
      if (emailExists) {
        setState(() {
          _emailError = 'This email is already registered. Please use another email or sign in.';
        });
        isValid = false;
      }
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Please enter a password';
      });
      isValid = false;
    } else if (!_isPasswordValid(password)) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters with uppercase, number, and special character';
      });
      isValid = false;
    }

    if (phoneNumber.isEmpty) {
      setState(() {
        _phoneError = 'Please enter your phone number';
      });
      isValid = false;
    } else if (!phoneNumber.startsWith('+')) {
      setState(() {
        _phoneError = 'Please include country code (e.g., +1 for US)';
      });
      isValid = false;
    }

    if (phoneNumber.isEmpty) {
      setState(() {
        _phoneError = 'Please enter your phone number';
      });
      isValid = false;
    } else if (!phoneNumber.startsWith('+')) {
      setState(() {
        _phoneError = 'Please include country code (e.g., +1 for US)';
      });
      isValid = false;
    }
    return isValid;
  }

  Future<bool> _isPhoneNumberValid(String phoneNumber) async {
  return true; 
}


  // Method to verify phone number and send SMS code
  Future<String> _verifyPhoneNumber(String phoneNumber) {
    final Completer<String> completer = Completer<String>();

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        completer.complete('');
      },
      verificationFailed: (FirebaseAuthException e) {
        String errorMessage;

        if (e.code == 'invalid-phone-number') {
          errorMessage = "Invalid phone number format.";
          setState(() {
            _phoneError = errorMessage;
          });
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Too many attempts. Please try again later.";
          setState(() {
            _phoneError = errorMessage;
          });
        } else if (e.code == 'credential-already-in-use' || 
                   e.code == 'phone-number-already-exists' ||
                   e.message?.contains('already') == true) {
          errorMessage = "This phone number is already registered.";
          setState(() {
            _phoneError = errorMessage;
          });
        } else {
          errorMessage = e.message ?? "An error occurred during phone verification.";
        }

        setState(() {
          _isLoading = false;
        });

        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        completer.complete(verificationId);
      },
    );

    return completer.future;
  }
  
  void _signUp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    bool isValid = await _validateInputs();
    
    if (!isValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    String phoneNumber = _phoneController.text.trim();
    bool phoneValid = await _isPhoneNumberValid(phoneNumber);
    
    if (!phoneValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();

    try {
      final verificationId = await _verifyPhoneNumber(phoneNumber);

      if (verificationId.isNotEmpty) {
        final smsCode = await promptUserForSmsCode(context);

        final phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
        final user = userCredential.user;

        if (user != null) {
          try {
            // link email/password to this phone-authenticated user
            final emailCredential = EmailAuthProvider.credential(
              email: email,
              password: password,
            );

            await user.linkWithCredential(emailCredential);

            await _firestoreService.saveUserData(user.uid, email, name);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sign-Up Successful!"), backgroundColor: Colors.green),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GDPRConsentScreen(
                  userId: user.uid,
                  email: email,
                  name: name,
                ),
              ),
            );
          } on FirebaseAuthException catch (e) {
            if (e.code == 'email-already-in-use') {
              setState(() {
                _emailError = 'This email is already associated with another account.';
                _isLoading = false;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? "An error occurred"), backgroundColor: Colors.red),
              );
              setState(() {
                _isLoading = false;
              });
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered. Please use another email or sign in.";
      } else if (e.code == 'invalid-phone-number' || e.message?.contains('phone') == true) {
        errorMessage = "This phone number is already in use or invalid.";
      } else {
        errorMessage = e.message ?? "An error occurred during sign up.";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred."), backgroundColor: Colors.red),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Icon(
                  Icons.restaurant,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: _nameError,
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: _emailError,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: _passwordError,
                  helperText: "Min 8 characters with uppercase, number & special character",
                ),
                obscureText: _obscureText,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number (with country code)",
                  hintText: "+1xxxxxxxxxx",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: _phoneError,
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 24),
              

              
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  },
  child: Text("Log In"),
),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}