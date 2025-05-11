import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'widgets/user_profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late User? currentUser;
  UserProfile? userProfile;
  bool isLoading = true;
  bool isEditing = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  final List<String> dietOptions = [
    'Vegetarian', 'Vegan', 'Pescatarian', 'Keto', 
    'Paleo', 'Low Carb', 'Gluten Free', 'Dairy Free'
  ];
  
  final List<String> commonAllergies = [
    'Peanuts', 'Tree Nuts', 'Milk', 'Eggs', 'Fish', 
    'Shellfish', 'Soy', 'Wheat', 'Sesame'
  ];

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    if (currentUser == null) return;
    
    try {
      setState(() {
        isLoading = true;
      });
      
      DocumentSnapshot doc = await _firestoreService.getUserData(currentUser!.uid);
      
      if (doc.exists) {
        await _firestoreService.ensureUserHasAllergiesField(currentUser!.uid);
        doc = await _firestoreService.getUserData(currentUser!.uid);
        
        setState(() {
          userProfile = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
          _nameController.text = userProfile!.name;
          _emailController.text = userProfile!.email;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing && userProfile != null) {
        // Reset controllers if canceling edit
        _nameController.text = userProfile!.name;
        _emailController.text = userProfile!.email;
      }
    });
  }

  Future<void> saveProfile() async {
    if (userProfile == null) return;
    
    try {
      setState(() {
        isLoading = true;
      });
      
      
      userProfile!.name = _nameController.text.trim();
      userProfile!.email = _emailController.text.trim();
      
      // Save to Firestore
      await _firestoreService.updateUserProfile(userProfile!);
      
      if (currentUser?.displayName != userProfile!.name) {
        await currentUser?.updateDisplayName(userProfile!.name);
      }
      
      setState(() {
        isLoading = false;
        isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e"), backgroundColor: Colors.red),
      );
    }
  }
  

void _navigateToPasswordReset() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PasswordResetScreen(),
    ),
  );
}


  void toggleDietaryPreference(String diet) {
    if (userProfile == null) return;
    
    setState(() {
      if (userProfile!.dietaryPreferences.contains(diet)) {
        userProfile!.dietaryPreferences.remove(diet);
      } else {
        userProfile!.dietaryPreferences.add(diet);
      }
    });
  }
  
  void toggleAllergy(String allergy) {
    if (userProfile == null) return;
    
    setState(() {
      if (userProfile!.allergies.contains(allergy)) {
        userProfile!.allergies.remove(allergy);
      } else {
        userProfile!.allergies.add(allergy);
      }
    });
  }

// Method to handle account deletion
void _showDeleteAccountDialog() {
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Delete Account"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Warning: This action cannot be undone. All your data will be permanently deleted.",
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                Text(
                  "Please enter your password to confirm:",
                ),
                SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: obscurePassword,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteAccount(passwordController.text);
                },
                child: Text("Delete Account"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

// Method to actually delete the account after confirmation
Future<void> _deleteAccount(String password) async {
  if (password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password is required"), backgroundColor: Colors.red),
    );
    return;
  }
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(width: 20),
            Text("Deleting account...")
          ],
        ),
      );
    },
  );
  
  try {
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    
    // Reauthenticate
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    
    await user.reauthenticateWithCredential(credential);
    
    // Delete user data from Firestore first
    await _deleteUserData(user.uid);
    
    await user.delete();
    
    Navigator.of(context, rootNavigator: true).pop();
    
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    
  } on FirebaseAuthException catch (e) {
    Navigator.of(context, rootNavigator: true).pop();
    
    String errorMessage = "An error occurred";
    
    if (e.code == 'wrong-password') {
      errorMessage = "Incorrect password";
    } else if (e.code == 'requires-recent-login') {
      errorMessage = "Please sign out and sign in again before deleting your account";
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
    );
  }
}

// Method to delete user data from Firestore
Future<void> _deleteUserData(String userId) async {
  try {
    await FirebaseFirestore.instance.collection("Users").doc(userId).delete();
    
    final batch = FirebaseFirestore.instance.batch();
    
    final savedRecipes = await FirebaseFirestore.instance
      .collection("SavedRecipes")
      .where("userId", isEqualTo: userId)
      .get();
      
    savedRecipes.docs.forEach((doc) {
      batch.delete(doc.reference);
    });
    
    final mealPlans = await FirebaseFirestore.instance
      .collection("MealPlans")
      .where("userId", isEqualTo: userId)
      .get();
      
    mealPlans.docs.forEach((doc) {
      batch.delete(doc.reference);
    });
    
    await batch.commit();
    
    print("User data deleted successfully");
  } catch (e) {
    print(" Error deleting user data: $e");
    throw e; 
  }
}
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("My Profile"),
          backgroundColor: Colors.green[600],
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("My Profile"),
          backgroundColor: Colors.green[600],
        ),
        body: Center(child: Text("Could not load profile")),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Colors.green[600],
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: toggleEditing,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            SizedBox(height: 24),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Basic Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    isEditing
                      ? TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                          ),
                        )
                      : ListTile(
                          title: Text("Name"),
                          subtitle: Text(userProfile!.name),
                          leading: Icon(Icons.person, color: Colors.green),
                          contentPadding: EdgeInsets.zero,
                        ),
                    SizedBox(height: 16),
                    isEditing
                      ? TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                          enabled: false,
                        )
                      : ListTile(
                          title: Text("Email"),
                          subtitle: Text(userProfile!.email),
                          leading: Icon(Icons.email, color: Colors.green),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SizedBox(height: 8),
if (isEditing)
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: OutlinedButton.icon(
  icon: Icon(Icons.lock_reset),
  label: Text("Change Password"),
  onPressed: _navigateToPasswordReset,
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.green,
  ),
),

  ),
                    SizedBox(height: 8),
                    ListTile(
                      title: Text("Membership"),
                      subtitle: Text(
                        userProfile!.membershipTier.toUpperCase(),
                        style: TextStyle(
                          color: userProfile!.membershipTier == 'premium' 
                            ? Colors.amber[700] 
                            : Colors.grey[600],
                        ),
                      ),
                      leading: Icon(
                        Icons.card_membership, 
                        color: userProfile!.membershipTier == 'premium' 
                          ? Colors.amber[700] 
                          : Colors.green,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Dietary preferences section
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dietary Preferences",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isEditing)
                          TextButton(
                            onPressed: () async {
                              if (userProfile != null) {
                                await _firestoreService.updateUserField(
                                  userProfile!.userId, 
                                  'dietaryPreferences', 
                                  userProfile!.dietaryPreferences
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Dietary preferences saved"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: Text("Save"),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dietOptions.map((diet) {
                        final isSelected = userProfile!.dietaryPreferences.contains(diet);
                        return FilterChip(
                          label: Text(diet),
                          selected: isSelected,
                          onSelected: isEditing 
                            ? (selected) => toggleDietaryPreference(diet)
                            : null,
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.green[100],
                          checkmarkColor: Colors.green,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Allergies section
            Card(
  elevation: 2,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Allergies",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isEditing)
              TextButton(
                onPressed: () async {
                  if (userProfile != null) {
                    await _firestoreService.updateUserField(
                      userProfile!.userId, 
                      'allergies', 
                      userProfile!.allergies
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Allergies saved"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text("Save"),
              ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonAllergies.map((allergy) {
            final isSelected = userProfile!.allergies.contains(allergy);
            return FilterChip(
              label: Text(allergy),
              selected: isSelected,
              onSelected: isEditing 
                ? (selected) => toggleAllergy(allergy)
                : null,
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.red[100],
              checkmarkColor: Colors.red,
            );
          }).toList(),
        ),
      ],
    ),
  ),
),
            
            SizedBox(height: 24),
            
            if (isEditing)
              Center(
                child: ElevatedButton(
                  onPressed: saveProfile,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    child: Text(
                      "Save Profile",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              if (isEditing)
  Center(
    child: ElevatedButton(
      onPressed: _showDeleteAccountDialog,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Text(
          "Delete Account",
          style: TextStyle(fontSize: 16),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  ),

          ],
        ),
      ),
    );
  }
}

class PasswordResetScreen extends StatefulWidget {
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _resetPassword() async {
    final String currentPassword = _currentPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();
    
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required"), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("New passwords don't match"), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password must be at least 6 characters"), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Create credential with email and current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      await user.updatePassword(newPassword);
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password updated successfully"), backgroundColor: Colors.green),
      );
      
      // Return to previous screen
      Navigator.of(context).pop();
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      String errorMessage = "An error occurred";
      
      if (e.code == 'wrong-password') {
        errorMessage = "Current password is incorrect";
      } else if (e.code == 'weak-password') {
        errorMessage = "The password is too weak";
      } else if (e.code == 'requires-recent-login') {
        errorMessage = "Please sign out and sign in again before changing your password";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
        backgroundColor: Colors.green[600],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureCurrentPassword,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureNewPassword,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text("Update Password"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}