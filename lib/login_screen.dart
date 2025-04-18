import 'package:flutter/material.dart';
import 'package:project_pic2plate/signup_screen.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'home_page.dart';
import 'widgets/mfa_dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isResetting = false;
  String? _errorMessage;
  String? _resetMessage;
  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _signIn() async {
    // Clear previous errors
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          setState(() {
            _errorMessage = "User data not found. Please contact support.";
            _isLoading = false;
          });
        }
      }
    } on FirebaseAuthMultiFactorException catch (e) {
      _handleMfaException(e);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            _errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            _errorMessage = 'The email address is invalid.';
            break;
          case 'user-disabled':
            _errorMessage = 'This account has been disabled.';
            break;
          default:
            _errorMessage = 'Login failed: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
      print('Sign-In Error: $e');
    }
  }

  Future<void> _handleMfaException(FirebaseAuthMultiFactorException e) async {
    setState(() {
      _isLoading = false;
    });
    
    final resolver = e.resolver;
    final phoneHint = resolver.hints.first as PhoneMultiFactorInfo;
    final session = resolver.session;
    
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneHint.phoneNumber,
        multiFactorSession: session,
        verificationCompleted: (PhoneAuthCredential credential) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone verification completed automatically')),
          );
        },
        verificationFailed: (FirebaseAuthException error) {
          setState(() {
            _errorMessage = 'Verification failed: ${error.message}';
          });
        },
        codeSent: (String verificationId, int? resendToken) async {
          try {
            final smsCode = await promptUserForSmsCode(context);
            if (smsCode != null && smsCode.isNotEmpty) {
              setState(() {
                _isLoading = true;
              });
              
              final phoneAuthCredential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: smsCode,
              );
              final assertion = PhoneMultiFactorGenerator.getAssertion(phoneAuthCredential);
              await resolver.resolveSignIn(assertion);
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          } catch (e) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'MFA verification failed: $e';
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'MFA setup error: $e';
      });
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      setState(() {
        _isResetting = true;
        _resetMessage = null;
      });
      
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      setState(() {
        _isResetting = false;
        _resetMessage = "Password reset email sent! Check your inbox.";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isResetting = false;
        switch (e.code) {
          case 'user-not-found':
            _resetMessage = 'No user found with this email.';
            break;
          case 'invalid-email':
            _resetMessage = 'The email address is invalid.';
            break;
          default:
            _resetMessage = 'Error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isResetting = false;
        _resetMessage = 'An unexpected error occurred.';
      });
      print('Password Reset Error: $e');
    }
  }
Future<void> resetPasswordInApp(String email, String newPassword) async {
  try {
    setState(() {
      _isResetting = true;
      _resetMessage = null;
    });

    String currentPassword = _currentPasswordController.text.trim();

    //  Sign in the user
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: currentPassword);

    User? user = userCredential.user;

    if (user == null) {
      setState(() {
        _isResetting = false;
        _resetMessage = 'Could not authenticate user.';
      });
      return;
    }

    // Update the password
    await user.updatePassword(newPassword);

    // track reset in Firestore
    await _firestoreService.updateUserPassword(user.uid, newPassword);

    setState(() {
      _isResetting = false;
      _resetMessage = 'Password updated successfully';
    });
  } on FirebaseAuthException catch (e) {
    setState(() {
      _isResetting = false;
      switch (e.code) {
        case 'wrong-password':
          _resetMessage = 'Incorrect current password';
          break;
        case 'user-not-found':
          _resetMessage = 'No user found with this email.';
          break;
        case 'requires-recent-login':
          _resetMessage = 'Please sign in again and try.';
          break;
        default:
          _resetMessage = 'Error: ${e.message}';
      }
    });
  } catch (e) {
    setState(() {
      _isResetting = false;
      _resetMessage = 'Unexpected error occurred.';
    });
    print("Password reset error: $e");
  }
}


  void _showForgotPasswordDialog() {
    // Pre-fill email if it's already entered in the login form
    if (_resetEmailController.text.isEmpty && _emailController.text.isNotEmpty) {
      _resetEmailController.text = _emailController.text;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: SingleChildScrollView(
                child: Form(
                  key: _resetFormKey,
                  child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Text(
      'Enter your current credentials and new password.',
      style: TextStyle(fontSize: 14),
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _resetEmailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your email';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _currentPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Current Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your current password';
        }
        return null;
      },
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _newPasswordController,
      obscureText: _obscureNewPassword,
      decoration: InputDecoration(
        labelText: "New Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setDialogState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a new password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: "Confirm Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setDialogState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please confirm your password';
        if (value != _newPasswordController.text) return 'Passwords do not match';
        return null;
      },
    ),
    const SizedBox(height: 16),
    if (_resetMessage != null)
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _resetMessage!.contains('successfully')
              ? Colors.green.shade50
              : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _resetMessage!,
          style: TextStyle(
            color: _resetMessage!.contains('successfully')
                ? Colors.green
                : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      ),
  ],
),

                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetEmailController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                    _currentPasswordController.clear();

                    _resetMessage = null;
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isResetting
                      ? null
                      : () async {
                          if (_resetFormKey.currentState!.validate()) {
                            String email = _resetEmailController.text.trim();
                            String newPassword = _newPasswordController.text;
                            
                            await resetPasswordInApp(email, newPassword);
                            setDialogState(() {}); // Update the dialog state
                            
                            // Auto-close the dialog after successful reset
                            if (_resetMessage != null && _resetMessage!.contains('successfully')) {
                              Future.delayed(const Duration(seconds: 2), () {
                                if (Navigator.canPop(context)) {
                                  Navigator.of(context).pop();
                                }
                              });
                            }
                          }
                        },
                  child: _isResetting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Reset Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    _newPasswordController.dispose();
    _currentPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 24),
                  
                  Text(
                    "Pic2Plate",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  
                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _showForgotPasswordDialog();
                      },
                      child: Text("Forgot Password?"),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_errorMessage != null) SizedBox(height: 16),
                  
                  // Login button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Log In",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  SizedBox(height: 24),
                  
                  // Sign up option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  },
                        child: Text("Sign Up"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}